function l = p2mtt_lfps(mtank, block)
%function l = p2mtt_lfps(mtank, block)
%  pull LFP data from TDT datatank (converted with converttank.exe)
%
%INPUT
%  mtank - string containing path to matlab-converted datatank
%  block - string indicating the block to extract
%
%OUTPUT
%      l - LFP data stream (all channels)
%
%Thu Aug  7 15:59:12 2008 mazer 

h = ttload(mtank, block);
l = {};

for n=1:length(h.has_lfp)
  if h.has_lfp(n)
    l{n} = ttloadlfp(mtank, block, n);
  else
    l{n} = [];
  end
end

fprintf('%s: lfp channels:%s\n', mtank, sprintf(' %d', find(h.has_lfp)));

