function oldstate = uni(state)
%function oldstate = uni(state)
%
%  Toggle automatic extraction of uni state -- this is to save time
%  when you're recording. Uni
%
%  INPUT:
%    state -- 'ON'/1 or 'OFF'/0
%             If state is not specified, report current state.
%
%  OUTPUT:
%    boolean initial state on call (call w/o args to just query state)
%
%  NOTES:
%    Fri Feb  1 14:58:17 2013 mazer 
%
%  HISTORY:
%    Wed Jun 23 09:20:18 2010 mazer 
%    Fri Feb  1 14:59:27 2013 mazer -- added persistent state
%      using matlab's getpref/setpref functions
%

verbose=0;

oldstate = getpref('uni', 'uniGen', 1);
if nargin > 0
  switch lower(state)
    case {'off', '0', 0}
      setpref('uni', 'uniGen', 0);
      if verbose, fprintf('[Uni file generation DISABLED]\n'); end
    case {'on', '1', 1}
      setpref('uni', 'uniGen', 1);
      if verbose, fprintf('[Uni file generation ENABLED]\n'); end
    otherwise
      error('uni ON|OFF or 0|1')
  end
end
