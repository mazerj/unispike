function [lfp, spk, wideband] = tdtgetraw(index, ch, want)
%
% returns two row vectors -- first row is TIME, second is VOLTAGE
%

persistent n60 lp hp

lfpcut = 200;
spikecut = 5000;

if ~exist('want', 'var')
  % l = lfp stream (lowpass)
  % s = spike stream (bandpass)
  % w = wideband (notch filtered only)
  want = 'sl';
end


ix = find(index.icode == icode('RAW0') & index.channel == ch);
fs = index.frequency(ix(1));

if isempty(n60)
  fprintf('[making notch filter (fs=%.0f)', fs);
  % Npoles NotchFreq Qual
  n60 = design(fdesign.notch(4, 60, 10, fs));
  fprintf(']\n');
end

if isempty(lp) && any(want=='l')
  fprintf('[making lfp filter (fs=%.0f)', fs);
  % Fpass Fstop Apass Astop
  lp = design(fdesign.lowpass(lfpcut, 2*lfpcut, 0.1, 25, fs));
  fprintf(']\n');
end

if isempty(hp) && any(want=='s')
  fprintf('[making spike filter (fs=%.0f)', fs);
  % default for design is an equiripple filter, which takes
  % ~20s just to compute. Kaiser looks ok -- longer filter,
  % and more group delay, but we're going to filter with
  % filtfilt, which should eliminate the (flat) group
  % delay...
  %
  % Fstop1 Fpass1 Fpass2 Fstop2 Astop1 Apass1 Astop2:
  hp = design(fdesign.bandpass(lfpcut/2, lfpcut, ...
                               spikecut, 2*spikecut, 25, 0.1, 25, fs), ...
              'kaiserwin');
  fprintf(']\n');
end

d = tdtraw(index, ix);

d(2,:) = filter(n60, d(2,:));

spk = [];
lfp = [];
wideband = [];

if any(want == 'w')
  wideband = d;
end

if any(want == 's')
  spk = [d(1,:); filtfilt(hp.Numerator, 1, d(2,:))];
end

if any(want == 'l')
  % low pass filter and then manually decimate -- warning, this
  % make mean the time values end short..
  d(2,:) = filtfilt(lp.Numerator, 1, d(2,:));
  while (fs / 2) > (2*lfpcut)
    d = d(:, 1:2:end);
    fs = fs / 2;
  end
  lfp = d;
end




