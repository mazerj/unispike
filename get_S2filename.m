function fname = get_S2filename(f)
%% Get the name of the S2 file associated with pype file
% Input: 
% - f: pf.src filename
% Output:
% - fname: filename of associated spike2 file
% Notes:
% - Looks on the RAID first. If not found, looks on the rig
% machine, and, if that fails, asks users to find the file
% themselves. Does not work for p2mCombine'd files.

fname = '';

[~, b c]=fileparts(f);
b = [b c '.smr'];

%% Search various places for the Spike2 file
cmds = {['fslocate -backups ' b], ...
        sprintf('find /auto/ferret1e/Ferret -name ''%s''', b) };
for ii=1:length(cmds)    
  [stat, result] = unix(cmds{ii});
  if stat == 0
    fname = result(1:end-1);
  end
  
  if (~isempty(fname))
    break;
  end
end

%% If all else fails, pop up a dialog box and let the user sort it out.
if isempty(fname)
  [fn pn] = uigetfile({'/auto/ferret1e/Ferret/*.smr'}, ...
                      ['Spike2 file for ' b]);
  if (isa(fn, 'char') && isa(pn, 'char'))
    fname = fullfile(pn, fn);
  else
    error('p2mS2:NoS2', 'Cannot find S2 file for %s\n', b);
  end
end
