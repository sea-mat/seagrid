function hello(varargin)

% hello -- Display a message.
%  hello(theMessage) displays 'hello' plus theMessage.

% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, theMessage = ''; end

s = [' ## hello'];

for i = 1:length(varargin)
   s = [s ' ' mat2str(varargin{i})];
end

disp(s)
