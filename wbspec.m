function wbspec(pf, chn)
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

% compute sampling frequency
fs = round(1/diff(wb{chn}.global_ti(1:2)));

H = spectrum.welch;

% plot power spectrum
v = wb{chn}.v;

psd(H, v, 'Fs', fs, 'ConfLevel', 0.95);
title(pf.src);

