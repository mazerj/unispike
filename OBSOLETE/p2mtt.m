function [lfps, snips] = p2mtt(pf)
%function [lfps, snips] = p2mtt(pf)
%  Read spike and LFP data from TDT DataTank converted using
%  'converttool.exe'. Data are converted to standardized format.
%
%INPUT
%      pf - p2m data structure
%
%OUTPUT
%    lfps - standardized format LFP data -- all channels
%  spikes - standardized format spike snippet data -- all channels
%
%Thu Aug  7 15:56:27 2008 mazer 

if ~isfield(pf.rec(1).params, 'tdt_tank')
  error('not a tdt datafile');
end

% tdt_tank is full pathname to raw tank -- strip off the last
% path component to find the mtank..
tdttank = pf.rec(1).params.tdt_tank;
ix = find(tdttank == '\');
if length(ix) > 0
  mtank = tdttank((ix(end)+1):end);
else
  mtank = tdttank(:);
end
block = pf.rec(1).params.tdt_block;
snips = p2mtt_snips(mtank, block);
lfps = p2mtt_lfps(mtank, block);


