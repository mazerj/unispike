function srcs = uniinfo(pf, showsnips, showlfps)
%function uniinfo(pf, [showsnips, showlfps])
%
% Show info about lfp and spike data generated from plxloader().
% By default
%
% INPUT
%   pf        - extended pf data structure from p2mLoad2()
%   showsnips - list of channels to show snips for (eg, 1:16)
%   showlfps  - list of channels to show lfps fo (eg, 1:16)
%
% OUTPUT
%  srcs - available spike and lfp data streams
%   srcs.snips is a 2xN table of channel/sortcodes
%   srcs.lfps is list of channels with lfp data
%
% NOTES
%
% Thu Oct  2 13:28:51 2008 mazer 

assert(isfield(pf, 'snips'), 'pf doesn''t have snip data -- use p2mLoad2');

if ~exist('showsnips', 'var')
  showsnips = [];
end
if ~exist('showlfps', 'var')
  showlfps = [];
end

lfps = pf.lfps;
snips = pf.snips;

if nargout == 0
  fprintf('lfp:\n');
  for n=1:length(lfps)
    if ~isempty(lfps{n})
      fprintf(' electrode #%d\n', lfps{n}.chan);
    end
  end
end

srcs = struct();
srcs.snips = [];
srcs.lfps = [];

if nargout == 0
  fprintf('snips:\n');
end
n = 0;
nchan = 0;
for j=1:length(snips)
  if ~isempty(snips{j});
    nchan = nchan + 1;
  end
end

for j=1:length(snips)
  if ~isempty(snips{j})
    slist = unique(snips{j}.sort);      % list of sorts
    for k=1:length(slist)
      srcs.snips = [srcs.snips; snips{j}.chan slist(k)];
      ix = find(snips{j}.sort == slist(k));
      m = snips{j}.v(:,ix)';
      t = 1000*repmat([snips{j}.t], length(ix), 1);
      v = nanmean(m);
      ve = nanstd(m);
      nspikes = size(m,1);
      if length(ix) > 1500
	r = randperm(size(m,1)); r = r(1:1500);
	m = m(r,:);
	t = t(r,:);
      end
      if any(snips{j}.chan == showsnips)
        if k == 1
          figure;
        end
        nr = round(sqrt(length(slist)));
        nc = ceil(length(slist)/nr);
        subplot(nr, nc, k);
	set(plot(t', m', '-'), 'color', [0.25 0.25 0.25])
	hold on;
	t = t(1,:);
	plot(t, v, 'w-', t, v-ve, 'r-', t, v+ve, 'r-');
	hold off;
	ylabel(sprintf('%d:%d n=%d/%.0f%%', ...
                       snips{j}.chan, slist(k), ...
                       nspikes, 100 * size(m,1) / nspikes));
      end
      if nargout == 0
	fprintf(' electrode #%d, sort #%d -- %d spikes\n', ...
		snips{j}.chan, slist(k), nspikes);
      end
    end
  end
end

if nargout == 0
  if isfield(pf, 'uniselect')
    sel = pf.uniselect;
  else
    sel = 'TTL';
  end
  fprintf('selected snip: [%s]\n', sel);
end


hasdata = [];
for n=1:length(pf.lfps)
  hasdata(n) = ~isempty(pf.lfps{n});
end
  
pn = 1;
for ch = find(hasdata)
  srcs.lfps = [srcs.lfps; ch];
  if any(ch == showlfps)
    figure;
    offset = 0;
    for n = 1:length(pf.lfps{ch}.ts)
      y = pf.lfps{ch}.lfp{n};
      y = y - mean(y);
      plot(pf.lfps{ch}.ts{n}, y-offset);
      hold on;
      offset = offset + max(abs(y));
    end
    hold off;
    title(sprintf('ch=%d', ch));
    ylabel('trial #');
    set(gca, 'YTickLabel', []);
    xlabel('time (s)');
    axis tight;
  end
end

