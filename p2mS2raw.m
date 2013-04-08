function s2 = p2mS2raw(S2file, vmoffset)
%function pf = p2mS2(S2file, vmoffset)
%
% Extract lfp, snip and spike data from Spike2 datafile. This is
% the working function used by p2mS2.m. The reason for the
% separation is to facilitate extracting S2 data from metarf
% datafiles -- one S2 files, many pypefiles..
%
%INPUT
%   S2file - p2m data structure
% vmoffset - voltage offset (intra-extra potential when pulling out)
%
%OUTPUT
%      s2 - data structure with per-trial Spike2 data. Data are
%      stored as follows, where 'n' is the trial number:
%        s2(n).units    - metal electrode voltage
%        s2(n).tunits   - metal time base (ms)
%        s2(n).iunits   - meta electrode Spike2 header info
%        s2(n).current  - injected current trace
%        s2(n).tcurrent - ...
%        s2(n).icurrent - ...
%        s2(n).lfp      - metal electrode lfp trace
%        s2(n).tlfp     - ...
%        s2(n).ilfp     - ...
%        s2(n).photo    - photo diode trace
%        s2(n).tphoto   - ...
%        s2(n).iphoto   - ...
%        s2(n).vm       - intracell voltage trace
%        s2(n).tvm      - ...
%        s2(n).ivm      - ...
%

fid = fopen(S2file, 'r');
if fid==-1
  error('p2mS2:OpenError', 'Unable to open %s', S2file);
end

%% Get channel titles instead of actual numbers
chanlist = SONChanList(fid);
channame = lower({chanlist.title});
channum = [chanlist.number];


%% Load the gating pulse, or fail if it's missing.
gateid = channum(strmatch('gate', channame));
if isempty(gateid)
  error('p2mS2:NoGate', 'Gating pulse is missing from S2 file %s', S2file);
end
[tgate, gate, ~] = loadS2chn(fid, gateid);

thresh = (max(gate) - min(gate)) / 2.0;
t = [0; diff(gate > thresh)];
starts = tgate(t == 1);
stops = tgate(t == -1);

if abs(length(starts) - length(stops)) > 1
  error('p2mS2:MidTrial', 'Mismatched start/stop events');
end

if (length(stops) - length(starts)) == 1
  stops = stops(2:end);
  warning('p2mS2:MidTrial', 'S2 starts midtrial; dropped initial stop');
end

if (length(starts) - length(stops)) == 1
  starts = starts(2:end);
  warning('p2mS2:MidTrial', 'S2 has trailing start, dropped');
end


cnames = {'units', 'current', 'lfp', 'photo', 'vm intra', 'wideband'};

for k = 1:length(cnames)
  chn  = channum(strmatch(cnames{k}, channame));
  try
      [t, y, h] = loadS2chn(fid, chn);
  catch E
     warning('p2mS2:MissingChan', 'Cannnot find channel %s. Available channels are %s', cnames{k}, sprintf('%s, ', channame{:}));
     continue;
  end
      
  if strcmp(cnames{k}, 'vm intra')
    tag = 'vm';
    y = y - vmoffset; %Remove pipette offset
  else
    tag = cnames{k};
  end

  for n = 1:length(starts)
    % this was referenced to the START event, but it's not
    % necessary, since the START event always has t=0, but
    % definition -- this makes it possible to generate synchronized
    % timestamps without access to the p2m file!
    ix = find(t >= starts(n) & t < stops(n));
    s2(n).(tag) = y(ix);
    s2(n).(['t' tag]) = (t(ix) - t(ix(1))) .* 1000.0;
    s2(n).(['i' tag]) = h;
    fprintf('.');
  end
end
fprintf('\n');
fclose(fid);

% for future info, but probably shouldn't really be used for anything
for ii = 1:length(s2)
    s2(ii).applied_vmoffset = vmoffset;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [t, y, h] = loadS2chn(fid, n)
[y, h] = SONGetChannel(fid, n);
if h.sampleinterval > 1
  h.sampleinterval = h.sampleinterval / 1e6;
end
t = (0:(length(y)-1)) .* h.sampleinterval;
t = t(:);
[y h] = SONADCToDouble(y, h);
t = t(:);
y = y(:);
return
