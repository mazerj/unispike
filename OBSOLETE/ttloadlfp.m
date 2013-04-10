function l = ttloadlfp(mtank, block, chan)
%function l = ttloadlfp(mtank, block, chan)
%  load LFP waveforms from specied block and channel
%
%INPUT
%  mtank - full path to mtank
%  block - string containing block name
%   chan - electrode #
%
%OUTPUT
%      l - standardarized lfp data stream
%
%Thu Aug  7 16:03:44 2008 mazer 

l.chan = chan;
l.lfp = {};
l.ts = {};
l.tnum = [];

info = ttload(mtank, block);
for n = 1:info.ntrials
  r = ttload(mtank, block, n);
  if isfield(r{chan}, 'time')
    % old style depot file...
    r{chan}.lfpt = r{chan}.time;
  end
  if length(r{chan}.lfp) ~= length(r{chan}.lfpt)
    % not sure why this happens:
    warning(['trial ' num2str(n) ': len(lfp) ~= len(lfpt)']);
  end
  l.lfp{n} = r{chan}.lfp;
  l.ts{n} = r{chan}.lfpt;
  l.tnum = [l.tnum n];
end

if nargout == 0
  offset = 0;
  for n = 1:info.ntrials
    if length(l.lfp{n}) == length(l.time{n})
      plot(l.time{n}, l.lfp{n}+offset);
      hold on;
      offset = offset + max(l.lfp{n});
      xlabel('uvolts');
      ylabel('ms');
    end
  end
end
