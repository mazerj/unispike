function indexlist = tdtopen(varargin)

if isstruct(varargin{1})
  %% Depending on when and where they were recorded, tank directories can
  %% be in several places. This is a list of places to search.
    search = {
      '/auto/data/critters/DataTanks/'
      '/auto/tdt1/DataTanks/'
      '/auto/tdt2/DataTanks/'
      };
  pf = varargin{1};
  
  
  blocklist = {};
  for n=1:length(pf.rec)
    blocklist{n} = pf.rec(n).params.tdt_block;
  end
  blocklist = unique(blocklist);
  
  %% Find the tank "name" (pic20100305) and search every location in the
  %% search list (above) for a corresponding directory
  tankname = pf.rec(1).params.tdt_tank;
  ix = find(tankname == '\');
  tankname = tankname(ix(end)+1:end);
  found = false;
  for n = 1:length(search)
    tank = [search{n} tankname];
    block = pf.rec(1).params.tdt_block;
    if exist(tank, 'dir')
      found = true;
      break;
    end
  end
  
  %% Sanity check
  if (found == false)
      error('tdtopen:NoTank', ...
            'Unable to locate %s. See if it''s readable', tankname);
  end
  
  for n = 1:length(blocklist)
    indexlist{n} = tdtraw(tank, blocklist{n});
  end
else
  tank = varargin{1};
  block = varargin{2};
  indexlist{1} = tdtraw(tank, block);
end
