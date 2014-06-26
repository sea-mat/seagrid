function [varargout] = inherit(theMethod, self, varargin)

% inherit -- Inherit a superclass method.
%  [varargout] = inherit('theMethod', self, varargin) calls
%   the superclass 'method' of self, an object, with the
%   given input and output arguments.  The routine
%   climbs the inheritance tree if needed.  (Multiple
%   inheritance is not supported here.)
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Dec-1999 22:50:19.
% Updated    08-Dec-1999 11:31:36.

if nargin < 2, help(mfilename), return, end

if ~isobject(self), return, end

% Clean up the name of the method.

f = find(theMethod =='/');
if any(f), theMethod(1:f(end)) = ''; end

theSuperObject = super(self);
varargout = cell(1, nargout);
varargin = [{theMethod}; varargin(:)];

while isobject(theSuperObject)
	varargin{1} = theSuperObject;
	try
		if nargout > 0
			[varargout{:}] = feval(theMethod, varargin{:});
		else
			feval(theMethod, varargin{:})
		end
	catch
	end
   theSuperObject = super(theSuperObject);
end
