function pf = p2mS2(pf, vmoffset, force)
%function pf = p2mS2(pf, vmoffset, force)
%
% Extract lfp, snip and spike data from Spike2 datafile. Try to
% decache the file first to speed things up. Calls p2mS2raw()
% to actually do the extraction.
%
% Note that the timebases for the Spike2 data are the nativek
% S2 timebases -- no effort is made to resample to match the
% 1khz pypefile time bases. However, the timebases are all properly
% aligned with the pypefile.
%
% This only works with Spike2 files that contain a valid 'gate',
% the trigger pulse sent out by pype to make the beginning and end
% of each trial.
%
%INPUT
%       pf - p2m data structure
% vmoffset - voltage offset (intra-extra potential when pulling out)
%    force - force loading (ignore cache)
%
%OUTPUT
%      pf.s2 - data structure with pypedata aligned Spike2 data. Data
%             are stored as follows, where 'n' is the trial number:
%        s2(n).units    - metal electrode voltage
%        s2(n).tunits   - metal time base (ms)
%        s2(n).iunits   - meta electrode Spike2 header info
%        s2(n).current  - injected current trace
%        s2(n).tcurrent - ...
%        s2(n).icurrent - ...
%        s2(n).lfp      - metal electrode lfp trace
%        s2(n).tlfp     - ...
%        s2(n).ilfp     - ...
%        s2(n).photo    - photo diode trace
%        s2(n).tphoto   - ...
%        s2(n).iphoto   - ...
%        s2(n).vm       - intracell voltage trace
%        s2(n).tvm      - ...
%        s2(n).ivm      - ...
%

%% If we're given a list of cell arrays, process each element in turn
if isa(pf, 'cell')
    for ii=1:length(pf)
        pf{ii} = p2mS2(pf{ii}, vmoffset, force);
    end
    return;
end
        


pf = getpf(pf);

if ~exist('force', 'var');
  force = 0;
end

if ~(isfield(pf.rec(1).params, 'acute') && pf.rec(1).params.acute==1)
  error('p2mS2:NotAcute', 'not an acute Spike2 datafile');
end

%% Check for the cachefile
[cachefile usecache] = check_cache(pf);

%% If there's a valid cache, load it and we're done
if usecache && force==0
  load(cachefile, '-mat')
  fprintf('[decached %s]\n', cachefile);
  pf.s2 = s2; %#ok<NODEF> (s2 is loaded from cachefile)
  
  if (nargin>1)
    warning('p2mS2:Offset', ...
            'Can''t apply offset to cache data. Re-run with force=1');
  end
  
  return;
end

%% Otherwise, open the Spike2 file and generate the cache.
if ~exist('vmoffset', 'var');
  error('p2mS2:NoOffset', 'must specify vmoffset');
end
fname = get_S2filename(pf.src);
s2 = p2mS2raw(fname, vmoffset);

if length(pf.rec) ~= length(s2)
  error('p2mS2:LengthMismatch', 'pypefile has %d trials, Spike2 %d trials', ...
        length(pf.rec), length(s2));
end


%% Write the cache to disk (we do this in a try because we want to
%% be able to convert things even if the local directory is write-protected)
try
  save(cachefile, 's2', '-v7.3'); 
  fprintf('[cached %s]\n', cachefile);
catch E
  fprintf(1, 'Unable to write cache file: %s\n', getReport(E, 'basic'));
end

pf.s2 = s2;


function [cachefile usecache] = check_cache(pf)
%% Check if the S2 data has been extracted and cached already
% [cachefile usecache] = check_cache(pf)
% Input:
% - pf: p2m structure
% Output:
% - cachename: full path to the cached data
% - usecache: 1 if cache is exists and is up to data, 0 otherwise

[a b c] = fileparts(pf.src);
cachefile=fullfile(a, ['.' b c '.s2']);

if ~exist(cachefile, 'file')
  fprintf('[no cache -- building]\n');
  usecache = 0;
else
  cdate = dir(cachefile);
  odate = dir(pf.src);
  if cdate.datenum < odate.datenum
    fprintf('[cache out of date -- regenerating]\n');
    usecache = 0;
  else
    usecache = 1;
  end
end

