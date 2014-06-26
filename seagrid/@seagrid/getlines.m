function theResult = getlines(self, theLinesFile)

% seagrid/getlines -- Load and plot a lines.
%  getlines(self) loads and plots a lines file
%   on behalf of self, a "seagrid" object.  If no
%   filename is given, the current lines filename
%   in self is used.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 27-Apr-1999 08:48:25.
% Updated    11-Dec-2000 15:11:40.

if nargout > 0, theResult = self; end

if nargin < 1, help(mfilename), return, end

if nargin < 2
	theLinesFile = psget(self, 'itsLinesFile');
end

if ~isempty(theLinesFile) & ~any(theLinesFile == filesep)
	theLinesFile = which(theLinesFile);
end
psset(self, 'itsLinesFile', theLinesFile)

if isempty(theLinesFile), return, end

load(theLinesFile)
psset(self, 'itsLinesColor',[1 0 1]);
theLinesColor = psget(self, 'itsLinesColor');
theButtonDownFcn = get(gca, 'ButtonDownFcn');
h = findobj('Type', 'line', 'Tag', 'lines');
if any(h), delete(h), end

theProjection = psget(self, 'itsProjection');
switch theProjection   % Needs cleaning up.
case {'none', 'Geographic'}
	theProjection = 'Geographic';
	x = lon; y = lat;
otherwise
	sg_proj(theProjection)
	[x, y] = sg_ll2xy(lon, lat);
	x = real(x);
	y = real(y);
end

hold on
h = plot(x, y, '-', 'Color', theLinesColor, ...
						'Tag', 'lines');
hold off
zoomsafe 0
set([gca h], 'ButtonDownFcn', theButtonDownFcn)
switch theProjection
case 'none'
	xlabel('Longitude')
	ylabel('Latitude')
otherwise
	xlabel('X')
	ylabel('Y')
	title([theProjection ' Projection'])
end

self = doupdate(self);

if nargout > 0, theResult = self; end
