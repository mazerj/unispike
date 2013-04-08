function [chnmask chnlist] = tdtgetchns(index)
forceSearch = 0; %Still searches, but tries to read the CHNS info first

chnmask = zeros([32 1]);
chns = find(index.icode == icode('CHNS'));
if ~forceSearch && ~isempty(chns) && sum(index.strobe(chns) ~= 0)
  for k=1:length(chns)
    for n=0:(size(chnmask,1)-1)
      if bitand(index.strobe(chns(k)), 2.^n)
        chnmask(n+1) = 1;
      end
    end
  end
  chnlist = find(chnmask);
else
  % no CHNS data -- not set, or predates CHNS.. try to use snips to guess..
  chnlist = unique(index.channel(ismember(index.icode, [icode('Snip'), icode('eNeu')])))';
  chnmask(chnlist) = 1;
end

