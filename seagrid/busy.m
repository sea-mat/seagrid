function Busy(theFigure)

% Busy -- Set the watch-cursor.
%  Busy(theFigure) sets the watch-cursor in theFigure.
%   The companion routine is "Idle".
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.

if ~any(findobj('Type', 'figure')), return, end

if nargin < 1
   theFigure = gcf;
end

set(theFigure, 'Pointer', 'watch');
