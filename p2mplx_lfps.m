function l = p2mplx_lfps(lfps, ntrials)
%function l = p2mplx_lfps(pf, ntrials)
%
%INPUT
%  ntrials - number of trials in this dataset
%     lfps - from plxloader.m
%
%OUTPUT
%  standardized cell array of lfp data (all channels)
%
%Thu Aug  7 15:54:51 2008 mazer 

NCHAN=8;

l = {};

fs = NaN;

for ch = 1:NCHAN
  if isempty(lfps) || isempty(find(lfps(:,2) == ch))
    l{ch} = [];
  else
    ll = {};
    for n = 1:ntrials
      ll.ts{n} = lfps(find(lfps(:,1) == n & lfps(:,2) == ch), 3);
      ll.lfp{n} = lfps(find(lfps(:,1) == n & lfps(:,2) == ch), 4);
      ll.tnum(n) = n;
      ll.chan{n} = ch;
      if isnan(fs)
	fs = 1.0 / diff(ll.ts{n}(1:2));
      end
    end
    ll.chan = ch;
    l{ch} = ll;
  end
end

hasdata = [];
for n=1:length(l)
  hasdata(n) = ~isempty(l{n});
end
fprintf('lfp channels:%s\n', sprintf(' %d', find(hasdata)));
