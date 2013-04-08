function pf = p2mSubset(pf, range)
%function pf = p2mSubset(pf, range)
%
% Extract a subset of trials from a larger p2m dataset
%
% INPUT
%  pf -- pypedata file (from p2mLoad or p2mLoad2)
%  range -- vector of trials to extract (these are KEEPERS)
%           range can also be 'even' or 'odd'
%
% OUTPUT
%  pf -- new pf structure containin just the indicated trials
%
% NOTE -- no effort is made to renumber the actual trial numbers -- these
%   will be maintained as in the original data structure
%
%Thu Dec  4 14:28:03 2008 mazer
%
%Tue Mar 23 09:58:29 2010 mazer  -- added 'odd'/'even' specification

% take the requested trials from the pypedata file

if strncmp(range, 'odd', 3)
  range = 1:2:length(pf.rec);
  tag = '[odds]';
elseif strncmp(range, 'even', 4)
  range = 2:2:length(pf.rec);
  tag = '[evens]';
else
  tag = '[subset]';

end
pf.rec = pf.rec(range);
pf.src = [pf.src ' ' tag];

% same for LFP data, if it exists (p2mLoad2 only)
if isfield(pf,'lfps')
  for n = 1:length(pf.lfps)
    if ~isempty(pf.lfps{n})
      pf.lfps{n}.ts = pf.lfps{n}.ts(range);
      pf.lfps{n}.lfp = pf.lfps{n}.lfp(range);
      pf.lfps{n}.tnum = pf.lfps{n}.tnum(range);
    end
  end
end

% same for snip data, if it exists (p2mLoad2 only)
if isfield(pf,'snips')
  for n = 1:length(pf.snips)
    if ~isempty(pf.snips{n})
      ix = [];
      for k = 1:length(range)
	ix = [ix find(pf.snips{n}.tnum == range(k))];
      end
      pf.snips{n}.v =  pf.snips{n}.v(:,ix);
      pf.snips{n}.ts =  pf.snips{n}.ts(ix);
      pf.snips{n}.sort =  pf.snips{n}.sort(ix);
      
      tnum = pf.snips{n}.tnum(ix);
      new = unique(tnum);
      for k = 1:length(new)
        tnum(tnum == new(k)) = k;
      end
      pf.snips{n}.tnum =  tnum;
    end
  end
end
