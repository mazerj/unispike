function pca_snips(pf, chan, npc)
%function pca_snips(pf, chan, [npc])
%
%  Compute principle components/eigenvectors of spike snip data
%  and project spikes onto PCs pairwise.
%
% INPUT
%   pf - extended p2m struct -- see p2mLoad2()
%   chan - channel number (1-nchan)
%   npcs - optional # of PCs to use (defaults to 75% variance)
%
% OUTPUT
%  (plot)
%
% NOTE
%  only used a limited/random # of snips to compute PCs!
%
%Fri Aug  8 10:23:43 2008 mazer 

assert(isfield(pf, 'snips'), 'pf doesn''t have snip data -- try p2mLoad2');

snips = pf.snips{chan};

MAXSNIPS = 1000;

if size(snips.v, 2) > MAXSNIPS
  ix = randperm(MAXSNIPS);
  [u,s,v] = svd(snips.v(:,ix));
else
  [u,s,v] = svd(snips.v);
end

if ~exist('npc', 'var')
  % use enough eigenvectors to cover 75% of the variance
  cs = find(cumsum(diag(s) ./ sum(diag(s))) > 0.75);
  npc = cs(1)-1;
end

m=[];
for n = 1:npc
  for k=1:size(snips.v, 2)
    m(n,k) = u(:,n)' * snips.v(:,k);
  end
end
m = (m - mean(m(:))) ./ std(m(:));

units = unique(snips.sort);
c='rbygmckrbygmckrbygmckrbygmck';

for a = 1:npc
  for b = (a+1):npc
    subplot(npc, npc, (a-1)*npc+b);
    for n = 1:length(units)
      ix = find(units(n) == snips.sort);
      set(plot(m(a,ix), m(b,ix), [c(n) '.']), 'markersize', 1);
      hold on;
    end
    hold off;
    title(sprintf('%d-%d', a, b));
  end
end
subplot(npc, npc, 1);
ld = 100 * diag(s) ./ sum(diag(s));
plot(1:(npc+1), ld(1:(npc+1)), 'ro', (npc+1):length(ld), ld((npc+1):end), 'ko');
ylabel('%var exp');
xlabel('pc#');

subplot(npc, npc, npc+1);
ld = cumsum(ld);
plot(1:(npc+1), ld(1:(npc+1)), 'ro', (npc+1):length(ld), ld((npc+1):end), 'ko');
yrange(0, 110);
hline(75);
ylabel('%var exp');
xlabel('pc#');

subplot(2,2,3);
for n = 1:length(units)
  ix = find(units(n) == snips.sort);
  plot3(m(1,ix), m(2,ix), m(3,ix), [c(n) '.']);
  hold on;
end
hold off;
xlabel('pc1');
ylabel('pc2');
zlabel('pc3');
grid on;

if ~isempty(pf)
  suptitle(pf.src);
end

