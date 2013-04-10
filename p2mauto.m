function state = p2mauto(state)
%function state = p2mauto(state)
%
%  Toggle automatic generation/updating of p2m files by p2mLoad2 
%
%  INPUT:
%    state -- 'ON'/1 or 'OFF'/0
%             If state is not specified, report current state.
%
%  OUTPUT:
%    boolean current state (after input state is applied); to query
%    current w/o changing, call with no args
%
%  HISTORY:
%    Tue Mar 12 14:47:55 2013 mazer -- new from uni.m

if nargin == 1
  switch lower(state)
    case {'off', '0', 0}
      setpref('uni', 'p2mauto', 0);
      fprintf('[automatic p2m DISABLED]\n');
    case {'on', '1', 1}
      setpref('uni', 'p2mauto', 1);
      fprintf('[automatic p2m ENABLED]\n');
    otherwise
      error('p2mauto ON|OFF or 0|1')
  end
end
state = getpref('uni', 'p2mauto', 1);
