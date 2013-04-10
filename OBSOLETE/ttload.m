function s = ttload(mtank, block, tnum)
%function s = ttload(mtank, block, [tnum])
%
%INPUT
%  mtank - generated version of tank (.mat files) -- directory!
%  block - name of block, eg 'Block-24'
%  tnum  - trial number, starting with 1 -- empty or omit for header info
%
%OUTPUT
%   s - either structure
%
%Thu Aug  7 16:02:48 2008 mazer 

if ~exist('tnum', 'var')
  tnum = [];
end

if ~ischar(block)
  block = sprintf('Block-%d', block);
end

mtank = ttfind(mtank);

try
  if isempty(tnum)
      tmp = load(sprintf('%s/%s/info.mat', mtank, block));
      s = tmp.info;
  else
      temp = load(sprintf('%s/%s/rec%03d.mat', mtank, block, tnum));
      s = temp.rec;
      for n=find(~cellfun(@isempty, s))
          if isstruct(s{n}.wbt)
              s{n}.wbt = linspace(s{n}.wbt.start, s{n}.wbt.stop, length(s{n}.wb))';
          end
          if isstruct(s{n}.lfpt)
              s{n}.lfpt = linspace(s{n}.lfpt.start, s{n}.lfpt.stop, length(s{n}.lfp))';
          end
      end
  end
catch E
  warning('unispike:ttload', 'Load failed: %s', E.message);
  s = [];
end
