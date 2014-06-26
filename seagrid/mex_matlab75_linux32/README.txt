Building SEAGRID from Source 

Building SEAGRID requires building 3 mex files:
mexsepeli.F
mexrect.F
mexinside.c

These mex files are machine dependent, and can also be matlab version dependent.

Here's how I built these files for Matlab7.5 (v2007b) on a 32 bit Linux platform
with g95 Fortran and gcc: 

Start up Matlab and type
>> mex -setup

Matlab will list the options files available for mex.

I chose option 1, "Template Options for building Fortran 90 MEX-files via the
system ANSI compiler", then noted where Matlab told me it stuck the "mexopts.sh" file it created.  
I copied that file over to my seagrid mexfile sourcecode directory.
Because I wanted to use the Intel Fortran compiler with 64 bit precision, I changed two lines in the mexopts.sh file:
#           FC='g95'
#           FFLAGS='-fexceptions'
            FC='ifort'
            FFLAGS='-real_size 64'

I then typed:
>> make_seagrid_mex

Which runs a script that calls mex using these mexopts.sh settings.


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
