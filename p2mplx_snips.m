function s = p2mplx_snips(spikes)
%function s = p2mplx_snips(spikes)
%
%INPUT
%  spikes - from plxloader.m
%
%OUTPUT
%  standardized cell array of spike data (all channels)
%
%Thu Aug  7 15:54:51 2008 mazer 

s = {};

snipsize = median(diff(find(isnan(spikes(:,6)))));
fs = NaN;

for ch = 1:8
  a = find(spikes(:,2) == ch & spikes(:,4) == 1);
  b = 1+find(spikes(:,2) == ch & spikes(:,4) == (snipsize-1));
  
  ss.v = zeros([snipsize-1 length(a)]);
  ss.ts = zeros([1 length(a)]);
  ss.sort = zeros([1 length(a)]);
  ss.tnum = zeros([1 length(a)]);
  ss.chan = ch;
  
  for k = 1:size(a,1)
    ss.v(:,k) = spikes(a(k):(b(k)-1),6);
    ss.sort(k) = spikes(a(k),3);
    ss.ts(:,k) = spikes(a(k),5);
    ss.tnum(k) = spikes(a(k), 1);
    if isnan(fs)
      fs = 1/((spikes(a(k)+1,5)-spikes(a(k),5) / 1) / 1000);
    end
  end
  ss.t = ((1:size(ss.v,1))-1) ./ fs;
  
  if isempty(ss.v)
    s{ch} = [];
  else
    s{ch} = ss;
  end
end

hasdata = [];
for n=1:length(s)
  hasdata(n) = ~isempty(s{n});
end
fprintf('snip channels:%s\n', sprintf(' %d', find(hasdata)));

