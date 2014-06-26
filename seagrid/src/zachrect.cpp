/*
 * mex routine implementing rect.f as taken from Ives, D.C. and
 * R. M. Zacharias "Conformal mapping and Orthogonal Grid
 * Generation", aiaa-87-2057.
 *
 * This mex-file is intended to be a private function.  It should
 * only be called from "mexrect.m" in the above directory.
 *
 *   >> zn = mexrect ( z, n );
 *
 */

// Define a complex datatype that we can pass off to fortran.
typedef struct mydcmplx_ {
	double r;
	double c;
} mydcmplx;

extern "C" {
	void rect_(mydcmplx *, int *, int *, int *, int *, int *);
}

#include "mex.h"

void mexFunction ( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] ) {
      
	// Shortcuts to the input arrays.
	const mxArray *zmx, *nmx;
	double *pzr, *pzi, *pn;

	// integer indices for the corner points
	int n1, n2, n3, n4;
	
	
	// The fortran routine requires the number of points.
	int numPoints;

	// We copy the input boundary array to this array, which we pass off
	// to the fortran routine.
	mydcmplx *z;

	// Loop index.
	int j;

	if ( nrhs != 2 ) {
		mexErrMsgIdAndTxt ( "SEAGRID:mexrect:badNumberOfAurgments", 
			"zachrect requires 2 input arguments." );
	}

	// Set up some short cuts to the data.
	zmx = prhs[0];
	pzr = mxGetPr(zmx);
	pzi = mxGetPi(zmx);

	nmx = prhs[1];
	pn = mxGetPr(nmx);
	n1 = static_cast<int>(pn[0]);
	n2 = static_cast<int>(pn[1]);
	n3 = static_cast<int>(pn[2]);
	n4 = static_cast<int>(pn[3]);


	if ( ! mxIsComplex(zmx) ) {
		mexErrMsgIdAndTxt ( "SEAGRID:mexrect:firstArgMustBeComplex", 
			"The first input argument must be complex." );
	}

	if ( ! mxIsNumeric(nmx) ) {
		mexErrMsgIdAndTxt ( "SEAGRID:mexrect:secondArgmentMust be real", 
			"The second input argument must be real." );
	}

	if ( mxGetNumberOfElements(nmx) != 4 ) {
		mexErrMsgIdAndTxt ( "SEAGRID:mexrect:badCountOn2ndArgument", 
			"The second input argument must have 4 elemens." );
	}
	

	// RECT requires the length of the boundary array.
	numPoints = mxGetNumberOfElements(zmx);

	// Allocate space for the boundary array as seen by FORTRAN.
	z = static_cast<mydcmplx*>(mxMalloc(numPoints * sizeof(mydcmplx)));

	for ( int j = 0; j < numPoints; ++j ) {
		z[j].r = pzr[j];
		z[j].c = pzi[j];
	}

	rect_ ( z, &numPoints, &n1, &n2, &n3, &n4 );

	// ok, now copy the results to the output array.
	const mwSize dims[2] = { numPoints, 1 };
	plhs[0] = mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxCOMPLEX);
	pzr = mxGetPr(plhs[0]);
	pzi = mxGetPi(plhs[0]);
	for ( int j = 0; j < numPoints; ++j ) {
		pzr[j] = z[j].r;
		pzi[j] = z[j].c;
	}


	mxFree(z);


}

