function mtank = ttfind(mtank)
%function mtank = ttfind(mtank)
%
% find complete path for specified 'matlab' tank (aka mtank)
% mtank's are generated from the original tdt tank by the matlab
% converttank tools (windows-only)
%
%INPUT
%  mtank - raw TDT data tank name (eg, from p2m struct)
%
%OUTPUT
%  mtank - full pathname to matching mtank on the fileserver
%
%Thu Aug  7 16:02:41 2008 mazer 

%          '/auto/oreganotank/X/',

depotpath = { '/auto/depot/mtanks/',
              '/auto/dilltank/X/',
              '/auto/clovetank/X/',
            };

if mtank(1) == '/'
  % absolute path -- don't try searching..
  if exist(mtank, 'dir')
    return;
  else
    error('can''t find: tank %s', mtank);
  end
else
  for n = 1:length(depotpath)
    depot = depotpath{n};
    if mtank(1) ~= '/'
      name = [depot mtank];
    end
    if exist(name, 'dir')
      mtank = name;
      return
    end
  end
end
error('can''t find: tank %s', mtank);
