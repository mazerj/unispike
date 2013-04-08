function y = icode(x)
%function y = icode(x)
%
% Convert back and forth between strings like 'Snip' or 'RAW0' used
% to name TDT data stores and long-ints for fast comparisions/search.
%
% USAGE
%   INT = icode('STR4');
%     or
%   STR4 = icode(INT);
%
%   STR4 is the 4-char store name (eg, 'RAW0')
%   INT is an int32 (4byte integer)
%

if ischar(x)
  if length(x) ~= 4
    error('Store names must be 4 chars long');
  end
  y = sum(x .* 2.^(8*(0:3)));
else
  shiftlist = -8*(0:3);
  str = '1234';
  for n=1:4
    str(n) = char(mod(bitshift(x, shiftlist(n)), 256));
  end
  y=str;
end
