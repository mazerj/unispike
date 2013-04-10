function wbplot(pf, chn)
%function wbspec(pf, chn)
%
%  plot wide-band power spectrum for entire run
%
%Mon Feb 20 16:14:33 2012 mazer 

pf = p2mLoad(pf);

if ~isfield(pf.rec(1).params, 'tdt_tank')
  error('wbspec only works with TDT datastreams');
end

% load continuous wideband signal
[~, ~, ~, wb] = p2mtdt(pf, 'w');

w = wb{chn};
s = 5*std(w.v);
clf;
for n = 1:max(w.tnum)
  v = w.v(w.tnum == n);
  t = w.trial_ti(w.tnum == n);
  plot(t, n + (v ./ s));
  hold on;
end
hold off;
