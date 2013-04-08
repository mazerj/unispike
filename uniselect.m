function pf = uniselect(pf, channel, sortcode)
%function pf = uniselect(pf, channel, sortcode)
%
% INPUTS 
%  pf -- existing p2m data structure with uni data (from p2mLoad2)
%  channel -- electrode number (first electrode is 1)
%  sortcode -- 0 is unsorted, 1 is first sort etc.. (-1 for ALL)
%
% OUTPUTS
%  pf - new p2m data struct with spike_times replaced by data from
%       the selected channel.
%
%  NOTE: if channel and sortcode are not specified, original pype-base
%        data stream (should be TTL) will be restored.
%
%Wed Dec  3 11:55:52 2008 mazer 
%
%9 March 2010 mattk: Updated to return spiketimes in ms (and as a column)
%to avoid breaking every other piece of code.

if ~exist('channel', 'var') || ~exist('sortcode', 'var')
  %
  % restore original pype-based spike data
  %
  if isfield(pf.rec, 'orig_spike_times')
    for n=1:length(pf.rec)
      pf.rec(n).spike_times = pf.rec(n).orig_spike_times;
    end
    pf.rec = rmfield(pf.rec, 'orig_spike_times');
  end
  if isfield(pf, 'uniselect')
    pf = rmfield(pf, 'uniselect');
  end
else
  %
  % replace pype data with snip data
  %
  assert(isfield(pf, 'snips'), 'pf doesn''t have snip data -- use p2mLoad2');
  assert(~isempty(pf.snips{channel}), 'no data on channel %d', channel);
  
  if ~isfield(pf.rec, 'orig_spike_times')
    % only do this once to save pype-base ttl spikes..
    for n=1:length(pf.rec)
      pf.rec(n).orig_spike_times = pf.rec(n).spike_times;
    end
  end
    
    
  for n=1:length(pf.rec)
    if sortcode >= 0
      ix = (pf.snips{channel}.tnum == n) & (pf.snips{channel}.sort == sortcode);
    else
      ix = (pf.snips{channel}.tnum == n);
    end
    pf.rec(n).spike_times = round(pf.snips{channel}.ts(ix)*1000)';
  end
  if sortcode >= 0
    pf.uniselect = sprintf('%d:%d', channel, sortcode);
  else
    pf.uniselect = sprintf('%d:ALL', channel);
  end
end
