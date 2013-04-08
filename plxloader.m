function [lfps, spikes, starts, stops] = plxloader(plxfile)
%function [lfps, spikes] = plxloader(plxfile)
%  Convert raw .PLX file to standardize TDT/PLEXON common data format
%
% INPUT
%   plxfile - full path to plexon-generated .PLX file
%
% OUTPUT
%    lfps   - [ [trial# chan pypetime voltage]; ...], where, 
%             'trial#' starts with 1
%             'chan' is the plexon 'sig' numner (electrode) (starts with 1)
%             'pypetime' is the trial time synced to pype (in SECS)
%             'voltage' is the raw spike voltage sample
%             NaN's  for voltage indicate trial boundaries
%    spikes - [ [trial# chan sortcode wave_ix pypetime voltage]; ..], where,
%             'trial#' starts with 1
%             'chan' is the plexon 'sig' numner (electrode) (starts with 1)
%             'sortcode' is 0 for unsorted, 1 for 'a',
%             'wave_ix' is the sample number for this snip
%             'pypetime' is the trial time synced to pype
%             'voltage' is the raw spike voltage sample
%             NaN's  for voltage indicate snip boundaries
%    starts - vector of trial start times relative to file onset (secs)
%    stops  - vector of trial stop times relative to file onset (secs)
%
% NOTES
%   this is about as fast is it can get..
%
%Thu Aug  7 09:46:16 2008 mazer -- created
%
%Thu Oct  9 10:33:11 2008 mazer --
% The plexon seems to be dropping trials -- starts/stops can be used
% in conjection with the 'trialtime' field in the p2m struct to identify
% the dropped trials and recover most of the data..
%
%
%Wed Oct 28 11:52:25 2009 mazer 
% Note that snip & LFP waveforms are converted to microvolts as they
% are loaded.
%

% Plexon type codes for DataRecords
PL_SPIKE=1;			% single spike waveform
PL_STEREO=2;			% stereotrode waveforms
PL_TETRO=3;			% tetrode waveforms
PL_EVENT=4;			% discrete event record
PL_SLOW=5;			% block of slow (lfp) data

% Plexon event codes
PL_XSTROBE=257;			% external strobe signal (?)
PL_XSTART=258;			% external start trigger
PL_XSTOP=259;			% external stop trigger
PL_PAUSE=260;			% ..not used..
PL_RESUME=261;			% ..not used..

f = fopen(plxfile, 'r');
h = FileHeader(f);

trnum = 0;
nrec = 0;
t0 = NaN;
adshift = NaN;

nlfps = 1;
lfps = [];
nspikes = 1;
spikes = [];
starts = [];
stops = [];

while 1
  d = DataRecord(f);
  if isempty(d.Type)
    % end of file
    break
  end
  nrec = nrec + 1;
  if d.Type == PL_EVENT && d.Channel == PL_XSTART
    starts = [starts (d.ts / h.ADFrequency)];
    if isnan(t0)
      t0 = d.ts;
      trnum = trnum + 1;
      fprintf('.');
    else
      error('double XSTART: trial %d\n', trnum);
    end
  elseif d.Type == PL_EVENT && d.Channel == PL_XSTOP
    stops = [stops  (d.ts / h.ADFrequency)];
    t0 = NaN;
  elseif d.Type == PL_SLOW && ~isnan(t0)
    if isnan(adshift)
      % assume the very first LFP sample in the file starts
      % at time ZERO (for pype, this is the same time as the
      % very first PL_XSTART). The assumption here is that
      % the NIDAQ card lags a bit behind the MAP box (group
      % delay), so timestamps are later than the actual time
      % the data came in, but the 1st sample should really be
      % zero..
      adshift = d.ts;
    end
    % compute timestamp in secs
    % Tue Sep 29 18:02:02 2009 mazer  -- seems like there's a missing 1000
    %   in the following low -- with the / 1000 you correctly get timestamps
    %   in secs. Without, everything's messed up..
    ts = (d.ts - t0 - adshift) / h.ADFrequency / 1000;
    ch = d.Channel+1;
    scale = h.SlowMaxMagnitudeMV / ...
	    (0.5 * (2.0.^h.BitsPerSlowSample) * ...
	     h.slows{ch}.Gain * h.slows{ch}.PreAmpGain);
    v = 1000.0 * d.waveform * scale;
    for i = 1:length(d.waveform)
      % convert waveform value to voltage (from plexon docs,
      % this is correct for file version >= 103 ONLY!)
      % note that refs for h.slow via d.Channel are correct, since
      % ... 'channel' values are 0-based for lfp..
      newrow = [trnum ch 1000*ts+(i/h.slows{ch}.ADFrequency) v(i)];
      if size(lfps, 1) < nlfps
	try
	  lfps = [lfps; zeros(size(lfps,1).^2, 4)];
	catch
	  lfps = [lfps; zeros(size(lfps,1)+1000, 4)];
	end
      end
      lfps(nlfps,:) = newrow(:);
      nlfps = nlfps + 1;
    end
  elseif d.Type == PL_SPIKE && ~isnan(t0)
    % compute timestamp in secs
    ts = (d.ts - t0) / h.ADFrequency;
    ch = d.Channel;
    scale = h.SpikeMaxMagnitudeMV / ...
	    (0.5 * (2.0.^h.BitsPerSpikeSample) * ...
	     h.channels{ch}.Gain * h.SpikePreAmpGain);
    v = 1000.0 * d.waveform * scale;
    for i = 1:length(d.waveform)
      % convert waveform value to voltage (from plexon docs,
      % this is corret for file version >= 103 ONLY!)
      % ... 'channel' values are 1-based for spikes...
      newrow = [trnum ch d.Unit i 1000*(ts+(i/h.ADFrequency)) v(i)];
      if size(spikes, 1) < nspikes
	try
	  spikes = [spikes; zeros(size(spikes,1)*2, 6)];
	catch
	  spikes = [spikes; zeros(size(spikes,1)+1000, 6)];
	end
      end
      spikes(nspikes,:) = newrow(:);
      nspikes = nspikes + 1;
    end
    if size(spikes, 1) < nspikes
      try
	spikes = [spikes; zeros(size(spikes,1).^2, 6)];
      catch
	spikes = [spikes; zeros(size(spikes,1)+1000, 6)];
      end
    end
    newrow(4:end) = NaN;
    spikes(nspikes,:) = newrow(:);
    nspikes = nspikes + 1;
  end
end
fprintf('\n');
% get rid of the allocated, but unused rows in spikes & lfps
spikes = spikes(1:(nspikes-1), :);
lfps = lfps(1:(nlfps-1), :);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x = rb(f, count, fmt)
switch fmt
 case 'I'
  x = fread(f, count, 'uint32');
 case 'i'
  x = fread(f, count, 'int32');
 case 'd'
  x = fread(f, count, 'double');
 case 'B'
  x = fread(f, count, 'uchar');
 case 'h'
  x = fread(f, count, 'short');
 case 'H'
  x = fread(f, count, 'int16');
 case 'L'
  x = fread(f, count, 'int32');
 case 's'
  x = fgets(f, count);
 case 'c'
  x = fread(f, count, 'char');
 otherwise
  error('unknown fmt code: %c', fmt);
end

function self = FileHeader(f)
start = ftell(f);
self.Magic = rb(f, 1, 'I');
if self.Magic ~= 1480936528		% 0x58454c50
  error('Not Plexon File')
end
fseek(f, start, -1);
		
self.Magic = rb(f, 1, 'I');
self.Version = rb(f, 1, 'i');
self.Comment = rb(f, 128 , 's');
		
self.ADFrequency = rb(f, 1, 'i');
self.NumDspChannels = rb(f, 1, 'i');
self.NumEventChannels = rb(f, 1, 'i');
self.NumSlowChannels = rb(f, 1, 'i');
self.NumPointsWave = rb(f, 1, 'i');
self.NumPointsPreThr = rb(f, 1, 'i');

self.Year = rb(f, 1, 'i');
self.Month = rb(f, 1, 'i');
self.Day = rb(f, 1, 'i');
self.Hour = rb(f, 1, 'i');
self.Min = rb(f, 1, 'i');
self.Sec = rb(f, 1, 'i');

self.FastRead = rb(f, 1, 'i');
self.WaveformFreq = rb(f, 1, 'i');
self.LastTimeStamp = rb(f, 1, 'd');

self.Trodalness = rb(f, 1, 'B');
self.DataTrodalness = rb(f, 1, 'B');
self.BitsPerSpikeSample = rb(f, 1, 'B');
self.BitsPerSlowSample = rb(f, 1, 'B');
self.SpikeMaxMagnitudeMV = rb(f, 1, 'h');
self.SlowMaxMagnitudeMV = rb(f, 1, 'h');
self.SpikePreAmpGain = rb(f, 1, 'h');

%{
% read to appropriate place in file
% constant part
% ...don't really know what this stuff is for...
tmp = rb(f, 5*130, 'i'); % tscounts header
tmp = rb(f, 5*130, 'i'); % wfcounts header
tmp = rb(f, 512, 'i');   % evcounts header
%}

fseek(f, start+7504, -1);
%fprintf('FileHeader: %d %d\n', start, ftell(f));


self.channels = {};
for i = 1:self.NumDspChannels
  self.channels{i} = ChannelHeader(f);
end
  
self.events = {};
for i = 1:self.NumEventChannels
  self.events{i} = EventHeader(f);
end
    
self.slows = {};
for i = 1:self.NumSlowChannels
  self.slows{i} = SlowHeader(f);
end
      
if ~isempty(self.slows)
  % all slow ad channels will have same speed..
  self.slow_adfreq = self.slows{1}.ADFrequency;
end

function self = ChannelHeader(f)
start = ftell(f);
self.Name = rb(f, 32, 's');
self.SIGName = rb(f, 32, 's');
self.Channel = rb(f, 1, 'i');
self.WFRate = rb(f, 1, 'i');
self.SIG = rb(f, 1, 'i');
self.Ref = rb(f, 1, 'i');
self.Gain = rb(f, 1, 'i');
self.Filter = rb(f, 1, 'i');
self.Threshold = rb(f, 1, 'i');
self.Method = rb(f, 1, 'i');
self.NUnits = rb(f, 1, 'i');
self.Template = rb(f, 5*64, 'h');
self.Fit = rb(f, 5, 'i');
self.SortWidth = rb(f, 1, 'i');
self.Boxes = rb(f, 5*2*4, 'h');
self.SortBeg = rb(f, 1, 'i');
self.Comment = rb(f, 128, 's');

fseek(f, start+1020, -1);
%fprintf('ChannelHeader: %d %d\n', start, ftell(f));

function self = EventHeader(f)
start = ftell(f);
self.Name = rb(f, 32, 's');
self.Channel = rb(f, 1, 'i');		% this channel is 1-based
self.Comment = rb(f, 128, 's');

fseek(f, start+296, -1);
%fprintf('EventHeader: %d %d\n', start, ftell(f));

function self = SlowHeader(f)
start = ftell(f);
self.Name = rb(f, 32, 's');
self.Channel = rb(f, 1, 'i');		% this channel is 0-based
self.ADFrequency = rb(f, 1, 'i');
self.Gain = rb(f, 1, 'i');
self.Enabled = rb(f, 1, 'i');
self.PreAmpGain = rb(f, 1, 'i');
self.spikechannel = rb(f, 1, 'i');
self.Comment = rb(f, 128, 's');

fseek(f, start+296, -1);
%fprintf('SlowHeader: %d %d\n', start, ftell(f));

function self = DataRecord(f)
start = ftell(f);
self.Type = rb(f, 1, 'h');
% timestampes are 40-bits (5 bytes)
% upper is upper byte, lower is lower 4 bytes
self.timestamp_upper = rb(f, 1, 'H');
self.timestamp_lower = rb(f, 1, 'L');

self.ts = (self.timestamp_upper*(2.^32)) + (self.timestamp_lower);

% channel and be a channel OR an event code!
% if type == PL_EVENT, it's an event code..
% and channel can be 0- or 1-based depending
% on whether it's a spike waveform or an LFP
% waveform
self.Channel = rb(f, 1, 'h');

% unit starts at 0, with 0=unsorted, 1='a' etc..
self.Unit = rb(f, 1, 'h');
self.NumberOfWaveforms = rb(f, 1, 'h');
self.NumberOfWordsInWaveform = rb(f, 1, 'h');

if (self.NumberOfWaveforms * self.NumberOfWordsInWaveform) > 0
  self.waveform = rb(f, self.NumberOfWordsInWaveform, 'h');
else
  self.waveform = [];
end

%fprintf('DataRecord: %d %d\n', start, ftell(f));
