function pf = unimerge(varargin)
%function pf = unimerge(varargin)
%
%  Combine p2m and unispike data structures from multiple runs into
%  a single structure
%
%
%INPUT
%  - list of p2m filenames or actual pf structs (from p2mLoad). These can
%  be passed as individual parameters: unimerge(pf1, pf2, ..., pfn) or as a
%  single cell array: unimerge(pflist);
%
%OUTPUT
%  pf - one giant pf data struct with all pf data
%
%NOTE
%  - Assumes uni files all have the same active channels.
%
%Fri Sep 26 15:33:52 2008 mazer 

pf.extradata = {};
pf.src = '';
pf.rec = [];

if nargin==1 && iscell(varargin{1})
    input = varargin{1};
else
    input = varargin;
end

for n = 1:length(input)
  p = input{n};
  
  if ischar(p)
    p = p2mLoad(p, [], 0);
  end
  [lfps, snips] = p2muni(p);
  fprintf('merging: %s (%d trials)\n', p.src, length(p.rec));
  
  pf.extradata{length(pf.extradata)+1} = p.extradata;
  if(isempty(pf.src))
      pf.src = p.src;
  else
      pf.src = [pf.src '+' p.src];
  end
  
  
  for j=1:length(p.rec)
    if isempty(pf.rec)
      pf.rec = p.rec(j);
    else
      pf.rec(length(pf.rec)+1) = p.rec(j);
    end
  end
  
  if n == 1
    % first time through, just copy the uni struct
    pf.lfps = lfps;
    pf.snips = snips;
  else
    % afterwards, we need to actually append
    %
    % NOTE: we are assuming that 1st file has same channel/electrode
    %       configuration as all the other files..
    %
    %       no need to mess about with '.chan', '.t' etc -- they should
    %       be correct as is..
    
    for k=1:length(snips)
      if ~isempty(snips{k})
	t0 = snips{k}.tnum(end);
	pf.snips{k}.v = [pf.snips{k}.v snips{k}.v];
	pf.snips{k}.ts = [pf.snips{k}.ts snips{k}.ts];
	pf.snips{k}.sort = [pf.snips{k}.sort snips{k}.sort];
	pf.snips{k}.tnum = [pf.snips{k}.tnum t0+snips{k}.tnum];
      end
    end
    
    for k = 1:length(lfps)
      if ~isempty(lfps{k})
	for kk = 1:length(lfps{k}.tnum)
          tnum = 1 + max(pf.lfps{1}.tnum);
          m = size(pf.lfps{1}.tnum,2) + 1;
	  pf.lfps{k}.ts{m} = lfps{k}.ts{kk};
	  pf.lfps{k}.lfp{m} = lfps{k}.lfp{kk};
	  pf.lfps{k}.tnum(m) = tnum;
        end
      end
    end
  end
end
