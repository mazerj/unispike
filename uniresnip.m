function pf = uniresnip(pf, nsigma)
%function pf = uniresnip(pf, nsigma)
%
% Generate new/synthetic *unsorted* snip data from wideband data stream.
%
% This basically lets you get a clean snip set where single voltage
% samples *can* twice in the dataset. This avoids any sort of hard
% refractory period associated with the window sizes for the real-time
% snip widget.
%
% INPUT
%   pf - p2mLoad2 struct
%   nsigma - threshold in units of voltage-STD
%
% OUTPUT
%   pf - with new snip data inserted (and also raw uncut spike data
%        if it hadn't already been loaded (pf.spks).
%
%Fri Nov 12 12:04:57 2010 mazer -- new

assert(isfield(pf.rec(1).params, 'tdt_tank'), ...
       'can only resnip TDT datastreams');

if ~exist('nsigma', 'var')
  nsigma=6;
end

if isfield(pf, 'spks')
  s = pf.spks;
else
  % pull spike data from tank
  [dummy, dummy, s] = p2mtdt(pf, 's');
  pf.spks = s;
end

fs = NaN;
pf.snips = {};
for ch = 1:length(s)
  if isempty(s{ch}), continue; end
  
  r = 0;
  for n = 1:length(s{ch}.tnum)
    v = s{ch}.spk{n};
    t = s{ch}.ts{n};
    r = r + std(v);
    if isnan(fs)
      fs = 1.0 / (t(2)-t(1));           % hz!
    end
  end
  r = r ./ n;
  npre = round((1/1000) * fs);
  npost = round((2/1000) * fs);
  t = (-1/1000):(1/fs):(2/1000); t = t - min(t);
  th = nsigma * r;
  snipv = []; snipts = []; sniptnum = []; snipsort = [];
  for n = 1:length(s{ch}.tnum)
    v = s{ch}.spk{n};
    dv = diff(v > th);
    if th > 0
      ix = find(diff(v > th) == 1);
    else
      ix = find(diff(v < th) == 1);
    end
    for k = ix'
      if (k - npre > 0) & (k + npost < length(v))
        snipv = [snipv v((k - npre):(k + npost))];
        % note: TS is time of threshold crossing, this matches the TDT
        % snip format..
        snipts = [snipts s{ch}.ts{n}(k)];
        sniptnum = [sniptnum n];
        snipsort = [snipsort 0];
        if 0
          subplot(2,1,1);
          plot(v((k - npre):(k + npost))); hline(th); yrange(-2*th,3*th);
          subplot(2,1,2);
          plot(dv((k - npre):(k + npost)));
          drawnow;        
          ginput(1);
        end
      end
    end
  end
  pf.snips{ch}.v = snipv;
  pf.snips{ch}.chan = ch;
  pf.snips{ch}.sort = snipsort;
  pf.snips{ch}.tnum = sniptnum;
  pf.snips{ch}.ts = snipts;
  pf.snips{ch}.t = t;
end

