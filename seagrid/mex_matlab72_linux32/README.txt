Building SEAGRID from Source 

Building SEAGRID requires building 3 mex files:
mexsepeli.F
mexrect.F
mexinside.c

These mex files are machine dependent, and can also be matlab version dependent.

Here's how I built these files for Matlab7.4 (v2007a) on a 32 bit Windows platform
with Intel Fortran for Windows 9.1 and LCC (the C compiler that Mathworks supplies):

Start up Matlab and type
>> mex -setup
and have Matlab look for Compilers on your system.   I choose Intel Fortran 9.1,
then noted where Matlab told me it stuck the "mexopts.bat" file it created.  
I copied that file over to my seagrid mex directory, and renamed it "mexopts_f.bat".
Because we want to compile with 64 bit precision, I added the flag /real_size:64 so
that the OPTIMFLAGS line in "mexopts_f.bat" reads:
set OPTIMFLAGS=/MD -Ox -DNDEBUG /real_size:64

I then did:
>> mex -setup 
a second time, and this time chose the LCC C compiler.  I copied the "mexopts.bat" file 
that Matlab created into my seagrid mex directoy and renamed it "mexopts_c.bat"

I then typed:
>> make_seagrid_mex

Which runs a script that calls mex using these mexopts_f.bat and mexopts_c.bat settings.


IMPORTANT NOTE FOR LARGE GRIDS: 

The maximum size of the grid that MEXSEPELI can
handle is set in mexsepeli.inc.   Because SEAGRID effectively
doubles the grid for computational purposes, if you need
a final grid that is 400x400, you need to set NX and NY in
mexsepeli.inc to something greater than 800.

Also the maximum size of the boundary that MEXRECT can
handle is set in mexrect.c.  You need to increase the size
of the Z array in the main routine, and also the size of R and T
in the RECT subroutine.

---
Rich Signell               |  rsignell@usgs.gov
U.S. Geological Survey     |  (508) 457-2229  |  FAX (508) 457-2310
384 Woods Hole Road        |  
Woods Hole, MA  02543-1598 |   
