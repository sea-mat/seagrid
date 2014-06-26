#include "string.h"
#include "mex.h"

// The calling sequence should be 
//   >> [x, y, perturb, ierror] = mexsepeli ( x, y, ...
//                                            l2, m2, ...
//                                            seta, sxi, ...
//                                            nwrk, nx2 );
//
//

#define NX 1200
#define NY 1200
#define NX2 (NX*2)
#define NY2 (NY*2)

extern "C" {
	// sepelieng_(m,n,tempx,tempy,&l2,&m2,seta,nseta,sxi,nsxi,px,py);
	void sepelieng_(int*, int*,double*,double*,double*,double*,double*,double*);

}


void mexFunction ( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
      
	int m2;
	int l2;

	double sxi[NX2+1];
	double seta[NY2+1];

	// Shortcuts to the input arrays.
	const mxArray *mxx, *mxy, *mxl2, *mxm2, *mxseta, *mxsxi;

	if ( nrhs != 6 ) {
		mexErrMsgIdAndTxt ( "SEAGRID:sepeli:badNumberOfAurgments", 
			"sepeli requires 6 input arguments." );
	}

	// Set up some short cuts to the data.
	mxx = prhs[0];
	mxy = prhs[1];
	mxl2 = prhs[2];
	mxm2 = prhs[3];
	mxseta = prhs[4];
	mxsxi = prhs[5];


	// Verify the input arguments
	if ( (!mxIsNumeric(mxx)) || (!mxIsNumeric(mxy)) || 
		 (!mxIsNumeric(mxl2)) || (!mxIsNumeric(mxm2)) || 
		 (!mxIsNumeric(mxseta)) || (!mxIsNumeric(mxsxi)) ) {
		mexErrMsgIdAndTxt ( "SEAGRID:sepeli:badInputArgumentType", 
			"Input arguments must be numeric." );
	}

	if ( (mxGetNumberOfElements(mxl2) != 1) || (mxGetNumberOfElements(mxm2) != 1)) {
		mexErrMsgIdAndTxt ( "SEAGRID:sepeli:badInputArgumentType", 
			"L2 and M2 arguments must be scalar." );
	}



	// copy x
	double *igridx = mxGetPr(mxx);
	const mwSize *dims = mxGetDimensions(mxx);

	int m = dims[0];
	int n = dims[1];
           

	// copy y
	double *igridy = mxGetPr(mxy);
           

	// copy l2
    double *pr = mxGetPr(mxl2);
	l2 = static_cast<int>(pr[0]); 
      
	// copy m2	  
    pr = mxGetPr(mxm2);
	m2 = static_cast<int>(pr[0]); 

	// copy seta
	pr = mxGetPr(mxseta);
	int nseta = mxGetNumberOfElements(mxseta);
	memcpy((void *)(seta),(const void *)pr,nseta*sizeof(double));
      
	// copy sxi
	pr = mxGetPr(mxsxi);
	mwSize nsxi = mxGetNumberOfElements(mxsxi);
	memcpy((void *)(sxi),(const void *)pr,nsxi*sizeof(double));
      

	// x
	plhs[0] = mxCreateNumericMatrix(m,n,mxDOUBLE_CLASS,mxREAL);
	dims = mxGetDimensions(plhs[0]);
	double *px = mxGetPr(plhs[0]);

	plhs[1] = mxCreateNumericMatrix(m,n,mxDOUBLE_CLASS,mxREAL);
	dims = mxGetDimensions(plhs[1]);
	double *py = mxGetPr(plhs[1]);

	// The fortran matrices are sized 0:m-1, 0:n-1
	sepelieng_(&m,&n, seta, sxi, igridx,igridy, px,py);



}

