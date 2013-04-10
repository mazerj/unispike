function s = ttloadsnips(mtank, block, chan)
%function s = ttloadsnips(mtank, block, chan)
%
% load all snips specied block and channel
%
%INPUT
%  mtank - full path to mtank
%  block - string containing block name
%   chan - electrode #
%
%OUTPUT
%      s - standardarized spike snip data stream
%
%Thu Aug  7 16:03:44 2008 mazer 


s.v = [];
s.chan = chan;
s.sort = [];
s.ts = [];
s.tnum = [];

info = ttload(mtank, block);
for n = 1:info.ntrials
  r = ttload(mtank, block, n);
  s.v = [s.v r{chan}.snips];
  s.sort = [s.sort r{chan}.snipsort];
  s.ts = [s.ts r{chan}.snipts];
  s.tnum = [s.tnum n+zeros(size(r{chan}.snipts))];
end
s.t = ((1:size(s.v,1))-1) ./ info.fs;

if nargout == 0
  units = unique(s.sort);
  for n = 1:length(units)
    ix = find(units(n) == s.sort);
    v = s.v(:,ix)*1e6;
    t = s.t;
    m = mean(v, 2);
    e = std(v, [], 2);
    subplot(length(units), 1, n);
    plot(t, v, 'k-', t, m, 'r-',  t, m-e, 'r-', t, m+e, 'r--');
    xlabel('uvolts');
    ylabel('ms');
    legend(sprintf('sort=%d', units(n)));
  end
end
