function s = p2mtt_snips(mtank, block)
%function s = p2mtt_snips(mtank, block)
%  pull spike snips from TDT datatank (converted with converttank.exe)
%
%INPUT
%  mtank - string containing path to matlab-converted datatank
%  block - string indicating the block to extract
%
%OUTPUT
%      l - spike data stream (all channels)
%
%Thu Aug  7 15:59:12 2008 mazer 

h = ttload(mtank, block);
s = {};

for n=1:length(h.has_snips)
  if h.has_snips(n)
    s{n} = ttloadsnips(mtank, block, n);
  else
    s{n} = [];
  end
end
fprintf('%s: snip channels:%s\n', mtank, sprintf(' %d', find(h.has_snips)));

