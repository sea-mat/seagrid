function [gx,gy] = mexsepeli(x,y,l2,m2,seta,sxi)
% MEXSEPELI wrapper function for sepeli mex-file
%
% [GX,GY] = mexsepeli(x,y,l2,m2,seta,sxi) returns an orthogonal 
% curvilinear grid.

[gx,gy] = grid_sepeli(x,y,l2,m2,seta,sxi);
