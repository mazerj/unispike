function state = uni(state)
%function state = uni(state)
%
%  Toggle automatic extraction of uni state -- this is to save time
%  when you're recording. Uni
%
%  INPUT:
%    state -- 'ON'/1 or 'OFF'/0
%             If state is not specified, report current state.
%
%  OUTPUT:
%    boolean current state (after input state is applied); to query
%    current w/o changing, call with no args
%
%  NOTES:
%    Fri Feb  1 14:58:17 2013 mazer 
%
%  HISTORY:
%    Wed Jun 23 09:20:18 2010 mazer 
%    Fri Feb  1 14:59:27 2013 mazer -- added persistent state
%      using matlab's getpref/setpref functions
%

if nargin == 1
  switch lower(state)
    case {'off', '0', 0}
      setpref('uni', 'uniGen', 0);
      fprintf('[Uni file generation DISABLED]\n');
    case {'on', '1', 1}
      setpref('uni', 'uniGen', 1);
      fprintf('[Uni file generation ENABLED]\n');
    otherwise
      error('uni ON|OFF or 0|1')
  end
end
state = getpref('uni', 'uniGen', 1);
