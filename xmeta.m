function xmeta(metapypefile, vmoffset)
%
% extract and generate .s2 cachefiles for metarf subfiles
%


%% We want the filename of the 'base' pype file, which may be slightly
% different from the input.
if isa(metapypefile, 'struct')
    metapypefile = metapypefile.src;
end

if strcmp(metapypefile(end-3:end), '.p2m')
    metapypefile=metapypefile(1:end-4);
end

%% Use the base name to find the smr and seq files
smrfile = get_S2filename(metapypefile);
seqfile = [metapypefile '.seq'];
f = fopen(seqfile, 'r');
if f < 0
  error('Can''t open %s', seqfile);
end

%% Parse up the seq file. Each line in the seq file looks like this:
% <trial number> <task name> <full path to pype "sub" file>
tasks = {};
tnums = [];
pypefiles = {};
while 1
  s = fgets(f);
  if ~ischar(s)
      break; 
  end
  
  s = strsplit(s(1:end-1), ' ');
  tnums(end + 1) = str2num(s{1});
  tasks{end + 1} = s{2};
  pypefiles{end + 1} = s{3};
end
fclose(f);
ufiles = unique(pypefiles);
fprintf('[%d sub-files]\n', length(ufiles));

%% Load all the S2 data in one go, then separate it out by task for the
% cachefiles.
s = p2mS2raw(smrfile, vmoffset);

for fn = 1:length(ufiles)
  f = ufiles{fn};
  [dirname filea fileb] = fileparts(f);
  
  cachefile = fullfile(dirname,  ['.' filea fileb '.s2']);
  ix = [];
  
  for n = 1:length(pypefiles)
    if strcmp(pypefiles{n}, f)
      ix = [ix n];
    end
  end
  
  s2 = s(ix);  %#ok<NASGU> (It's really used in the save below)
  try
      save(cachefile, 's2');
  catch E
      fprintf(1, 'Unable to write cache file: %s\n', getReport(E, 'basic'));
  end
  
  fprintf('[extracted %s]\n', f);
end

