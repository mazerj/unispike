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
% Thu Apr 10 17:04:17 2014 mazer 
%   - updated to use Mark Hanus' (@TDT) faster typecast version
%
if ischar(x)
  y = typecast(uint8(x), 'int32');
else
  y = char(typecast(x, 'uint8'));
end
