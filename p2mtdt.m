function [lfps, snips, spks, wbs] = p2mtdt(pf, what)
%function [lfps, snips, spks, wbs] = p2mtdt(pf, what)
%
% Native replacement for p2mtt() -- this uses tdtraw()-based funcionts
% to provide direct access to a raw tank file. This means there's no
% need for converttank.exe etc starting with this version
%
%INPUT
%      pf - p2m data structure
%      what -- char string indicating what to extract:
%          l: lfp (unsnipped lowpass)
%          s: spikes (unsnipped highpass)
%          S: snips
%          w: wide band (unfiltered continuous)
%
%OUTPUT
%    lfps - standardized format LFP data -- all channels
%   snips - standardized format spike snippet data -- all channels
%    spks - same format as lfps, but for highpass data
%     wbs - continuous wideband signal
%
%Tue Dec 29 17:11:28 2009 mazer 
%
%Thu Mar 11 12:22:02 2010 mazer 
%  Setup CHNS to be boolean mask vector. For example,
%    env CHNS=010101 p2muni foo.p2m
%  will extract data from channels 2, 4 & 6, overriding the GUI-set
%  toggle buttons in the pypet circuit.
%
%Mon Feb 20 16:00:29 2012 mazer 
%  Added 'w' wideband signal extraction

if ~isfield(pf.rec(1).params, 'tdt_tank')
  error('not a tdt datafile');
end

NCHAN = 16;

snips = [];
lfps = {};
spks = {};
wbs = {};

indexlist = tdtopen(pf);

mask  = getenv('CHNS');
if ~isempty(mask)
  k = 0 * (1:NCHAN);
  k(find(mask == '1')) = 1;
  user_chlist = find(k);
  fprintf('[user specified channels:');
  fprintf(' %d', user_chlist);
  fprintf(']\n');
else
  user_chlist = NaN;
end

for inum = 1:length(indexlist)
  index = indexlist{inum};

  if length(indexlist) > 1
    fprintf('[reading block #%d]\n', inum);
  end
  
  if ~isnan(user_chlist)
    chlist = user_chlist;
  else
    [~, chlist] = tdtgetchns(index);
  end
  [tstart, tstop] = tdtgettrials(index);
  
  if any(what == 'S')
    for ch = 1:NCHAN
      if ~any(chlist == ch)
        s = [];
      else
        [scodes stimes svolt] = tdtgetsnips(index, ch);
        if isempty(scodes)
          s = [];
        else
          s.v = svolt';                     % volts
          s.chan = ch;                      % scalar index (1-NCHANS)
          s.sort = scodes(2, :);            % sort code (0-n, 0 is unsorted)
          
          % Assign trial number based on snip start time and use
          % this info to compute timestamps relative to trial start
          % events. NaN tnum's reflect spikes between trials. We'll
          % get rid of these at the end.
          ts = stimes(:,1);
          tnum = NaN * zeros([1 size(svolt,1)]);
          for n = 1:length(tstart)
            ix = find(ts >= tstart(n) & ts <= tstop(n));
            tnum(ix) = n;
            ts(ix) = ts(ix) - tstart(n);
          end
          s.tnum = tnum;                      % save trial numbers
          s.ts = ts;                          % save timestamps in secs
          s.t = stimes(1,:)-stimes(1,1);      % save one time vector for plotting
          
          % Strip out snips between trials (mimic plexon gating system)
          ix = find(~isnan(tnum));
          s.v = s.v(:,ix);
          s.sort = s.sort(ix);
          s.ts = s.ts(ix)';
          s.tnum = s.tnum(ix);
        end
      end
      if (length(snips) < ch) || isempty(snips{ch})
        snips{ch} = s;
      else
        % append this block to the previous blocks
        tnum = tnum + max(snips{ch}.tnum);
        if ~isempty(s)
            snips{ch}.v = [snips{ch}.v s.v];
            %snips{ch}.chan = snips{ch}.chan;
            snips{ch}.sort = [snips{ch}.sort s.sort];
            snips{ch}.tnum = [snips{ch}.tnum s.tnum];
            snips{ch}.ts = [snips{ch}.ts s.ts];
            %snips{ch}.t = snips{ch}.t;
        end
      end
    end
  end
  
  if any(what == 'l')
    for ch = 1:NCHAN
      if ~any(chlist == ch)
        l = [];
      else
        [lfp dummy dummy] = tdtgetraw(index, ch, 'l');
        
        t = lfp(1, :);
        lfp = lfp(2, :);
        
        l.chan = ch;
        l.tnum = 1:length(tstart);
        
        for n = 1:length(tstart)
          ix = find(t >= tstart(n) & t < tstop(n));
          l.lfp{n} = lfp(ix)';
          l.ts{n} = t(ix)' - tstart(n);
        end
      end
      if (length(lfps) < ch) || isempty(lfps{ch})
        lfps{ch} = l;
      else
        %lfps{ch}.chan = lfps{ch}.chan;
        lfps{ch}.tnum = [lfps{ch}.tnum l.tnum + max(lfps{ch}.tnum)];
        lfps{ch}.lfp = [lfps{ch}.lfp l.lfp];
        lfps{ch}.ts = [lfps{ch}.ts l.ts];
      end
    end
  end
  
  if any(what == 's')
    for ch = 1:NCHAN
      if ~any(chlist == ch)
        s = [];
      else
        [~, spk, ~] = tdtgetraw(index, ch, 's');
        
        t = spk(1, :);
        spk = spk(2, :);
          
        s.chan = ch;
        s.tnum = 1:length(tstart);
          
        for n = 1:length(tstart)
          ix = find(t >= tstart(n) & t < tstop(n));
          s.spk{n} = spk(ix)';
          s.ts{n} = t(ix)' - tstart(n);
        end
      end
      if (length(spks) < ch) || isempty(spks{ch})
        spks{ch} = s;
      else
        %spks{ch}.chan = spks{ch}.chan;
        spks{ch}.tnum = [spks{ch}.tnum s.tnum + max(spks{ch}.tnum)];
        spks{ch}.spk = [spks{ch}.spk s.spk];
        spks{ch}.ts = [spks{ch}.ts s.ts];
      end
    end
  end
  
  if any(what == 'w')
    for ch = 1:NCHAN
      if ~any(chlist == ch)
        w = [];
      else
        [~, ~, wb] = tdtgetraw(index, ch, 'w');
        
        w.chan = ch;
        w.global_ti = wb(1, :);         % global time
        w.v = wb(2, :);                 % voltage
        
        w.tnum = zeros(size(w.global_ti)); % trial num (0 for ITI)
        w.trial_ti = zeros(size(w.global_ti)); % trial-based times
        
        for n = 1:length(tstart)
          ix = find(w.global_ti >= tstart(n) & w.global_ti < tstop(n));
          w.tnum(ix) = n;
          w.trial_ti(ix) =  w.global_ti(ix) - tstart(n);
        end
        
        if (length(wbs) < ch) || isempty(wbs{ch})
          wbs{ch} = w;
        else
          %wbs{ch}.chan = w.chan;
          wbs{ch}.global_ti = [wbs{ch}.global_ti w.global_ti];
          wbs{ch}.v = [wbs{ch}.v w.v];
          wbs{ch}.tnum = [wbs{ch}.tnum max(wbs{ch}.tnum)+w.tnum];
          wbs{ch}.trial_ti = [wbs{ch}.trial_ti w.trial_ti];
        end
      end
    end
  end
end
