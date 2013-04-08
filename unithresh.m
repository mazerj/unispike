function pf = unithresh(pf, nsigma)

assert(isfield(pf, 'snips'), 'pf doesn''t have snip data -- use p2mLoad2');

if ~exist('nsigma', 'var')
  nsigma = 5;
end


snips = pf.snips;

srcs.snips = [];
srcs.lfps = [];

for ch=1:length(snips)
  if isempty(pf.snips{ch}), continue; end

  m = pf.snips{ch}.v;
  m = m - repmat(mean(m), [size(m,1)  1]); % demean voltage traces
  th = nsigma .* mean(std(m,1));        % find threshold
  ix = find(sum((m > th) | (m < -th), 1)); % find supra-threshold events
  pf.snips{ch}.sort(:) = 0;             % reset all sort codes to unsorted
  pf.snips{ch}.sort(ix) = 1;            % all snips > thresh get code 1
  fprintf('%d %d\n', ch, length(ix));
end
