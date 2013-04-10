function pf = p2mtt_merge(pf, force)
%function pf = p2mtt_ttmerge(pf, force)
%  Collect snip data from 'matlab-datatank' and inject into a p2m
%  data structure as standard plexon event codes. This will basically
%  do the same thing as p2m'ing the file did, but doesn't require
%  an active TTank server running.
%
%INPUT
%  pf - p2m data structure
%
%OUTPUT
%  pf - modified p2m data structure with new (or updated) plx_XX fields
%
%NOTES
%  warning: this will delete any existing plx_XX data in the p2m struct
%
%Thu Aug  7 16:00:13 2008 mazer 

if ~exist('force', 'var')
  force = 0;
end

if isfield(pf.rec(1), 'plx_channels') & ~force
  error('plx data already exists -- use force to override');
end

try
  mtank = pf.rec(1).params.tdt_tank;
catch
  error('not a tdt datafile');
end
ix = find(mtank == '\');
if length(ix) > 0
  mtank = mtank((ix(end)+1):end);
end
block = pf.rec(1).params.tdt_block;

h = ttload(mtank, block);
s = p2mtt_snips(mtank, block);

for n = 1:length(pf.rec)
  pf.rec(n).plx_times = [];
  pf.rec(n).plx_channels = [];
  pf.rec(n).plx_units = [];
  for ch = 1:length(h.has_snips)
    if h.has_snips(ch)
      ix = find(s{ch}.tnum == n);
      t = s{ch}.ts(ix);
      pf.rec(n).plx_times = [pf.rec(n).plx_times t];
      pf.rec(n).plx_channels = [pf.rec(n).plx_channels (0*t)+s{ch}.chan];
      pf.rec(n).plx_units = [pf.rec(n).plx_units s{ch}.sort(ix)];
    end
  end
end

