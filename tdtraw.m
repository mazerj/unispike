function result = tdtraw(varargin)
%function result = tdtraw(varargin)
%
% Provides raw access to TDT Data Tanks (TSQ+TEV files). First time
% you should call this with the tank specification. In-memory index
% will be generated from the TSQ file. Subsequent calls pass in the
% index structure, which is used to retrieve raw data streams from
% the TEV file.
%
% USAGE
%   index = tdtraw(tankname, blockname)
%     -OR-
%   data = tdtraw(index, reclist)
%
% INPUT (varargin)
%   tankname  - name of tank directory as string
%   blockname - string name of block (eg, 'Block-27')
%     -OR-
%   index     - header data (see below)
%   reclist   - vector (or single scalar) of records to load
%   
% OUTPUT
%   index - structure containing the TSQ data (header info and
%           offsets into TEV file)
%     -OR-
%   data  - raw data -- reclist should be a vector of records to
%           load all at once to optimize reads (minimize fopen/fclose,
%           etc).
%
% AUTHOR:  Jamie Mazer <james.mazer@yale.edu> December 2009
%

if ischar(varargin{1})
  result = getindex(varargin{:});
elseif isstruct(varargin{1})
  result = getdata(varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function index = getindex(varargin)
% Load index data using memmap. Can't see this getting any faster.
% Now only requires single pass. Benches around 45k rec/s

tank = varargin{1};
block = varargin{2};

if isunix
  sep = '/';
else
  sep = '\\';
end

if tank(end) == sep
  tank = tank(1:(end-1));
end
ix = find(tank == sep);
tankdir = tank(1:end);
tankname = tank((1+ix(end)):end);

base = sprintf('%s/%s/%s_%s', tankdir, block, tankname, block);
index.tsqfile = [base '.tsq'];
index.tevfile = [base '.tev'];

%%BENCH%% tic;
mm = memmapfile(index.tsqfile, ...
                'Offset', 0,  ...
                'Format', { ...
                    'int32' [1 1] 'size'; ...
                    'int32' [1 1] 'type'; ...
                    'int32' [1 1] 'icode'; ...
                    'uint16' [1 1] 'channel'; ...
                    'uint16' [1 1] 'sortcode'; ...
                    'double' [1 1] 'timestamp'; ...
                    'uint64' [1 1] 'offset'; ...
                    'int32' [1 1] 'format'; ...
                    'single' [1 1] 'frequency'; ...
                   });
x = mm.Data(3:end-1);
index.size = double([x.size]);
index.type = double([x.type]);
index.icode = double([x.icode]);
index.channel = double([x.channel]);
index.sortcode = double([x.sortcode]);
index.timestamp = double([x.timestamp]);
offset = [x.offset];
index.offset = double(offset);
index.strobe = typecast(offset, 'double');
index.format = double([x.format]);
index.frequency = double([x.frequency]);

n = length(index.size);
%%BENCH%% fprintf('%.1f rec/s\n', n/toc);

function d = getdata(varargin)
% load raw data from the TEV file -- this is slow as hell, but
% can't really figure out any way to speed it up. Benches around
% 3500 ksamples/sec (depending on the record sizes -- RAW0 is
% faster than Snips due to larger record sizes)
%
% Note that Snip data is handled specially and the timestamps
% are corrected on the fly to generate real times that can be
% referenced directly to the raw tank data.

index = varargin{1};
ns = varargin{2};

%%BENCH%% tic;
%tev = fopen(index.tevfile, 'r');
nsamps = sum(index.size(ns) - 10);
%d = NaN * zeros([2 nsamps]);
d = zeros([2 nsamps]);
ix = 1;
snipcodes = [icode('Snip'), icode('eNeu')];
for n = ns
  sevfile = strrep(index.tevfile, '.tev', ...
                   sprintf('_%s_Ch%d.sev', ...
                           icode(index.icode(n)), ...
                           index.channel(n)));
  tev = fopen(sevfile, 'r');
  if tev < 0
    tev = fopen(index.tevfile, 'r');
  end
  if fseek(tev, index.offset(n), -1) < 0
    error(ferror(tev))
  end
  nlongs = index.size(n) - 10;          % in 4byte units
  switch index.format(n)
    case 0                              % DFORM_FLOAT
      nsamp = nlongs * 4 / 4;           % nlongs / sizeof(long) * size(float32)
      [v, cnt] = fread(tev, nsamp, 'float32', 0, 'a');
      if cnt ~= nsamp, error('ran out of float32 data'); end
      d(2,ix+(0:nsamp-1)) = v;
    case 1                              % DFORM_LONG
      nsamp = nlongs * 4 / 4;
      [v, cnt] = fread(tev, nsamp, 'int32', 0, 'a');
      if cnt ~= nsamp, error('ran out of 32 data'); end
      d(2,ix+(0:nsamp-1)) = v;
    case 2                              % DFORM_SHORT
      nsamp = nlongs * 4 / 2;
      [v, cnt] = fread(tev, nsamp, 'int16', 0, 'a');
      if cnt ~= nsamp, error('ran out of int16 data'); end
      d(2,ix+(0:nsamp-1)) = v;
    case 3                              % DFORM_BYTE
      nsamp = nlongs * 4 / 1;
      [v, cnt] = fread(tev, nsamp, 'int8', 0, 'a');
      if cnt ~= nsamp, error('ran out of int8 data'); end
      d(2,ix+(0:nsamp-1)) = v;
    case 4                              % DFORM_DOUBLE
      nsamp = nlongs * 4 / 8;
      [v, cnt] = fread(tev, nsamp, 'float64', 0, 'a');
      if cnt ~= nsamp, error('ran out of float64 data'); end
      d(2,ix+(0:nsamp-1)) = v;
    case 5                              % DFORM_QWORD
      nsamp = nlongs * 4 / 8;
      [v, cnt] = fread(tev, nsamp, 'int64', 0, 'a');
      if cnt ~= nsamp, error('ran out of int64 data'); end
      d(2,ix+(0:nsamp-1)) = v;
    otherwise
      error('unsupported TDT data format: #%d', index.format(n));
  end
  fclose(tev);
  t = index.timestamp(n) + ((0:(nsamp-1)) ./ index.frequency(n));;
  if ismember(index.icode(n), snipcodes)
    % snip timestamps indicate time of 1st threshold crossing, which is
    % 1/4 way into the trace, subtract this out:
    t = t - ((nsamp + 2) / 4) / index.frequency(n);
  end
  d(1,ix+(0:nsamp-1)) = t;
  ix = ix + nsamp;
end


%%BENCH%% fprintf('%.1f Ksamples/s\n', size(d, 2)/1000/toc);

