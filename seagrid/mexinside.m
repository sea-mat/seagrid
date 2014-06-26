function pts = mexinside(x,y,xb,yb)
% Given a point x,y and the series xb(k),yb(k) (k=1...nb) defining
% vertices of a closed polygon.  ind is set to 1 if the point is in
% the polygon and 0 if outside.  each time a new set of bound points
% is introduced ind should be set to 999 on input.
% it is best to do a series of y for a single fixed x.
% method ... a count is made of the no. of times the boundary cuts
% the meridian thru (x,y) south of (x,y).   an odd count indicates
% the point is inside , even indicates outside.
% see a long way from euclid by constance reid  p 174 .
% oceanography emr   oct/69
%
% The calling sequence from MATLAB should be
%
%   >> inside_inds = mexinside ( x, y, xb, yb );
%

pts = private_mexinside(x,y,xb,yb);
