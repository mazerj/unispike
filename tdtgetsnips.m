function [src, sniptimes, snips] = tdtgetsnips(index, ch)

if exist('ch', 'var')
  ix = find(ismember(index.icode, [icode('Snip'), icode('eNeu')]) & ...
            index.channel == ch);
else
  ix = find(ismember(index.icode, [icode('Snip'), icode('eNeu')]));
end

if isempty(ix)
  % no snips this channel (probably LFP only)
  snips = [];
  sniptimes = [];
  src = [];
else
  snipsize = index.size(ix(1)) - 10;
  d = tdtraw(index, ix);

  snips = reshape(d(2,:), [snipsize size(d,2)/snipsize])';
  sniptimes = reshape(d(1,:), [snipsize size(d,2)/snipsize])';
  src = [index.channel(ix); index.sortcode(ix)];
end

