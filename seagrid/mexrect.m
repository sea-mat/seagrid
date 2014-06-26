function oz = mexrect(z,np,n1,n2,n3,n4)
% MEXRECT backwards-compatible wrapper m-file for what used to be a 
% mex-file called mexrect.  The mex-file is now in the private directory
% and is called "zachrect"
oz = zachrect(z,[n1 n2 n3 n4]);
