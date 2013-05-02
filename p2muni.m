function [lfps, snips, spikes] = p2muni(pf, force)
%function [lfps, snips, spikes] = p2muni(pf, [force])
%  Read spike and LFP data from either TDT or Plexon data files
%  into standard 'unified' format (see HELP UNISPIKE)
%
%INPUT
%   pf    - p2m data structure OR name of p2m file OR cell array of p2m
%           filenames
%   force - (optional) don't use cache file and force reloading from orig src
%
%OUTPUT
%  lfps   - standardized format LFP data -- all channels
%  snip   - standardized format spike snippet data -- all channels
%  spikes - standardized format raw continuous (per trial) spike
%           data -- all channels
%
%NOTE
%  - If possible -- this cache's the resulting extracted data to a
%    file pf.src+'.uni'. The next time the data's loaded, the cached
%    version will be used if possible.
%
%Thu Aug  7 17:16:38 2008 mazer -- created
%
%Mon Sep 29 14:24:42 2008 mazer 
% made .uni file a hidden file to avoid problems & clutter..

if ~exist('force', 'var')
  force = 0;
end

if iscell(pf)
  % Called in batch mode -- if there's an error stop immediattely
  % and record the error. This is really for out-of-memory errors.
  for n = 1:length(pf)
    try
      p2muni(pf{n}, force);
    catch exception
      if strcmp(exception.identifier, 'MATLAB:nomem')
        fprintf('>> Out of memory processing:\n');
        fprintf('>>    %s\n', pf{n});
        fprintf('>> [error suppressed, continuing]\n');
      else
        fprintf(getReport(exception));
        fprintf('>> file: %s\n', pf{n});
        return
      end
    end
  end
  return
elseif ischar(pf)
  us=uni();
  try
    pf = p2mLoad2(pf);                  % p2mLoad2() handles .000 & 000.p2m...
    uni(us);
  catch
    uni(us);
  end
end

if length(pf.rec) < 1
  error('%s: empty', pf.src);
end

x = find(pf.src == '/');
if isempty(x)
  cachefile = ['.' pf.src '.uni'];
else
  cachefile = [pf.src(1:x(end)) '.' pf.src((x(end)+1):end) '.uni'];
end

if ~force && exist(cachefile, 'file')
  load(cachefile, '-mat')
  fprintf('[decached %s]\n', cachefile);
else
  fprintf('[extracting %s]\n', pf.src);
  if isfield(pf.rec(1).params, 'tdt_tank')
    % tucker-davis (TDT) recording
    [lfps, snips, spikes, ~] = p2mtdt(pf, 'lSs');
  elseif (isfield(pf.rec(1).params, 'acute') && pf.rec(1).params.acute==1)
    % spike2 datafile (acute prep) -- no snips (yet)
    error('Use p2mS2() for Spike2 datafiles');
    lfps = NaN; snips = NaN; spikes = NaN;
  else
    % plexon MAP box recording
    [lfps, snips] = p2mplx(pf);
    spikes = NaN;
  end
  if ~isempty(lfps) || ~isempty(snips)
    try
        fprintf('[caching %s]\n', cachefile);
        save(cachefile, 'lfps', 'snips', 'spikes');
        fprintf('[cached %s]\n', cachefile);
    catch E
        fprintf(1, 'Unable to write cachefile to disk: %s', getreport(E));
    end
  end
end

ok = 0;
for k = 1:length(lfps)
  if ~isempty(lfps{k})
    if length(pf.rec) > max(lfps{k}.tnum)
      fprintf('p2muni: %s\n', pf.src);
      fprintf('  TDT datasteam missing trials. Likely tank corruption.');
      fprintf('  Trim pf.rec(:) => (1:%d)\n', max(lfps{k}.tnum));
      break;
    elseif length(pf.rec) < max(lfps{k}.tnum)
      fprintf('p2muni: lfp data has too many trials: %s\n', pf.src);
      fprintf('        try updating p2m file!\n');
      break
    end
  end
end

