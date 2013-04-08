function [lfps, snips] = p2mplx(pf)
%function [lfps, snips] = p2mplx(pf)
%  Open and read spike and LFP data from raw plexon .PLX file associated
%  with p2m struct 'pf', then convert to standardized format
%
%INPUT
%      pf - p2m data structure
%OUTPUT
%    lfps - standardized format LFP data -- all channels
%  spikes - standardized format spike snippet data -- all channels
%
%Thu Aug  7 15:56:27 2008 mazer 
PLXDIR = '/auto/data/critters/PlexonData';

ix = find(pf.src == '/');
plxfile = [PLXDIR pf.src(ix(end):end) '.plx'];
if ~exist(plxfile, 'file')
  error('can''t find %s', plxfile);
end

if 1
  % use the most recent .plx file (in case there's been off-line sorting..)
  pat = strrep(plxfile, '.plx', '*.plx');
  [status, files] = unix(sprintf('/bin/ls -t1 %s', pat));
  ix = find(files==10);
  plxfile = files(1:(ix(1)-1));
  if length(ix) > 1
    fprintf('warning: multiple .plx files available -- using:\n %s\n', plxfile)
  end
end

[lfps, snips, starts, stops] = plxloader(plxfile);
% this reorders plexon data stream to account for missing trials in the
% sequence
[lfps, snips] = plxfix(pf, lfps, snips, starts, stops);
lfps = p2mplx_lfps(lfps, length(pf.rec));
snips = p2mplx_snips(snips);
