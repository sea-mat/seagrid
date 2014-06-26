To make the SEAGRID mexfiles from source, try just 
typing "make_seagrid_mex" from Matlab.  If that does
not work, you may need to modify the *.sh files to 
modify compiler options.

IMPORTANT NOTE FOR LARGE GRIDS: 

The maximum size of the grid that MEXSEPELI can
handle is set in mexsepeli.inc.   Because SEAGRID effectively
doubles the grid for computational purposes, if you need
a final grid that is 400x400, you need to set NX and NY in
mexsepeli.inc to something greater than 800.

Also the maximum size of the boundary that MEXRECT can
handle is set in mexrect.c.  You may need to increase the size
of the Z array.
---
Rich Signell               |  rsignell@crusty.er.usgs.gov
U.S. Geological Survey     |  (508) 457-2229  |  FAX (508) 457-2310
384 Woods Hole Road        |  http://crusty.er.usgs.gov/rsignell.html
Woods Hole, MA  02543-1598 |   
