function w = ttloadwb(mtank, block, chan)
%function w = ttloadwb(mtank, block, chan)
%  load wideband waveforms from specied block and channel
%
%INPUT
%  mtank - full path to mtank
%  block - string containing block name
%   chan - electrode #
%
%OUTPUT
%      w - standardarized wideband data stream (TDT ONLY)
%
%Fri Sep 26 14:20:26 2008 mazer 

w.chan = chan;
w.wb = {};
w.ts = {};
w.tnum = [];

info = ttload(mtank, block);
for n = 1:info.ntrials
  r = ttload(mtank, block, n);
  if length(r{chan}.wb) ~= length(r{chan}.wbt)
    % not sure why this happens:
    warning(['trial ' num2str(n) ': len(wb) ~= len(wbt)']);
  end
  w.wb{n} = r{chan}.wb;
  w.ts{n} = r{chan}.wbt;
  w.tnum = [w.tnum n];
end

if nargout == 0
  offset = 0;
  for n = 1:info.ntrials
    if length(w.wb{n}) == length(w.ts{n})
      plot(w.ts{n}, w.wb{n}+offset);
      hold on;
      offset = offset + max(w.wb{n});
      xlabel('uvolts');
      ylabel('ms');
    end
  end
end
