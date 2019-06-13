function pf = p2mLoad2(varargin)
%function pf = p2mLoad2(varargin)
%
% Extended version of p2mLoad -- knows about '.uni' files and also how
% to merge multiple p2m/uni files into a single data structure.
%
% INPUT
%  fname - filename to load -- must be a .p2m or .merge file!
%    - if fname is a regular .p2m file, just load it like p2mLoad()
%    - if fname is a .merge file, it should be a text file with one
%      p2m filename per line and the specified files will be loaded
%      into a single merged data structure.
%    - .merge files can also include lines indicate the chn and sortcode:
%         channel=1
%         sortcode=4
%         /this/is/file1.p2m
%         /this/is/file2.p2m
%      and uniselect() will be called automatically to select the
%      indicated spike channel.
%
% If p2m file doesn't exist (or is out of date), but the
% corresponding pype file exists, the p2m file will be
% automatically created or updated.
%
% p2mLoad2('nouni') and p2mLoad2('uni') turns automatic unifile
% generation off and on (for current session only!).
%
% If you don't specify a filename and one's been recently loaded,
% it'll return it..
%
% OUTPUT
%  pf  - composite p2m data structure
%
% NOTES
%  - even though this looks like a 'p2m' function, it's really part
%    of the unispike toolkit..
%
%Mon Sep 29 17:00:13 2008 mazer -- created
%
%Wed Mar 31 14:09:04 2010 mazer 
%  added 'skipuni' option via new p2mset() function.
%  to disable automatic uni extraction use can run:
%    >> p2mset('skipuni', 1)
%  To turn in back on, do:
%    >> p2mset('skipuni', [])
%
%Wed Jun 23 11:20:46 2010 mazer 
%  no need to use p2mset for skipping uni file generation, just do:
%    >> uni on
%  or
%    >> uni off
%
%Wed Jun 23 11:21:27 2010 mazer 
%  - added automatic freshening of p2m files
%  - made 'skipuni' stuff internal to p2mLoad2() -- only lasts for the
%    duration of the session!
%
%Thu Jul 12 09:37:39 2012 mazer 
%  - no args returns last loaded dataset
%  - adds .p2m suffix automatically if it's not there
%
%Tue Mar 12 14:59:12 2013 mazer 
%  - added p2mload2 [no]auto option to turn off automatic
%    freshening of p2m files


persistent lastLoaded

if (nargin == 0 && ~isempty(lastLoaded))
  pf = lastLoaded;
  fprintf('[uncached %s]\n', pf.src);
  return
end

assert(nargin > 0, 'must specify [NO]UNI, [NO]AUTO or FNAME');

if strcmpi(varargin{1}, 'nouni')
  uni(0);
  return
elseif strcmpi(varargin{1}, 'uni')
  uni(1);
  return
elseif strcmpi(varargin{1}, 'noauto')
  p2mauto(0);
  return
elseif strcmpi(varargin{1}, 'auto')
  p2mauto(1);
  return
else
  fname = varargin{1};
  uniGen = uni;
  autogen = p2mauto;
end

% if filename specifies a list of files, then merge them and return
flist = jls(fname);
if length(flist) > 1
  pfs = {};
  for n = 1:length(flist)
    pfs{n} = p2mLoad2(flist{n});
  end
  pf = p2mMerge(pfs);
  return
end

mergefile = 0;
switch filetype(fname)
  case 'merge'
    mergefile = 1;
  case 'p2m'
    fname = fname;
  otherwise
    fname = [fname '.p2m'];
end

p2mfile = fname;
pypefile = strrep(p2mfile, '.p2m', '');
if ~exist(pypefile, 'file')
  if ~exist(p2mfile, 'file')
    error('missing both p2mfile and pypefile');
  end
  pypefile = [];
end

if ~isempty(pypefile)
  pypefile_d = dir(pypefile);
  p2mfile_d = dir(p2mfile);
  if ~exist(p2mfile, 'file') || pypefile_d.datenum > p2mfile_d.datenum
    fprintf('[p2mLoad2: %s needs updating]\n', p2mfile);
    if autogen
      p2mBatch(pypefile, 1, 0);
    else
      fprintf('[p2mLoad2: automatic updating skipped]\n', p2mfile);
    end
  end
end

if ~mergefile
  pf = p2mLoad(fname, [], 0);
  if uniGen
    try
      [pf.lfps, pf.snips, pf.spikes] = p2muni(pf);
    catch
      fprintf('[p2mLoad2: found no uni data]\n', basename(fname));
    end
  end
  lastLoaded = pf;
else
  fprintf('[p2mLoad2: loading text file for merge]\n');

  channel = [];
  sortcode = [];

  f = fopen(fname, 'r');
  if f < 0
    error(['can''t open ' fname ' for reading']);
  end
  p2mfiles = {};
  while 1
    l = fgetl(f);
    if l < 0
      break
    end
    if length(l) > 0
      ix = find(l(1) == '%' || l(1) == '#');
      if ~isempty(ix)
        l = deblank(l(1:(ix(1)-1)));
      end
      x = sscanf(l, 'channel=%d');
      if ~isempty(x)
        channel = x;
        continue;
      end
      x = sscanf(l, 'sortcode=%d');
      if ~isempty(x)
        sortcode = x;
        continue;
      end    
      if ~isempty(l)
        p2mfiles{length(p2mfiles)+1} = l;
      end
    end
  end
  fclose(f);

  pf = unimerge(p2mfiles{:});
  if ~isempty(channel) && ~isempty(sortcode)
    pf = uniselect(pf, channel, sortcode);
  end
  lastLoaded = pf;
end

function x = endswith(s, suffix)
x = strcmp(s(end-length(suffix)+1:end), suffix);
%fprintf('%s, %s -> %d\n', s, suffix, x);
