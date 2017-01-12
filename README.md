seagrid
=======
Orthogonal curvilinear grid creator for Matlab
SeaGrid is a Matlab 5.2+ application for generating an orthogonal grid within a curved perimeter, suitable for oceanographic modeling.
 With SeaGrid, one can:

* Select a conformal map projection.
* Manually adjust grid corner points and curved boundaries.
* Modify the number of grid-cells and grid-line spacings.
* Compute depths, land-masking, and orthogonality.
* Save, then later reload a grid for further work.
* Port a grid to Matlab on another computer.
* Create ROMS, POM and ECOM grids.
* Get comprehensive built-in help.

Starting from a conformal projection (such as Mercator) of the targeted area, SeaGrid uses the Ives-Zacharias scheme to conformally map the curved perimeter to a rectangle, after which, a Poisson solver fills the interior with orthogonally distributed grid points. Control over such features as the number of grid-cells and the density of grid lines is provided by menus, dialogs, and direct graphical manipulation of objects in the program's display window. Behind the scenes, Seagrid uses a new object-oriented window manager (Presto), plus some Mex-files. None of these rely on optional MathWorks toolboxes.
 

## SeaGrid Contents

You will find these directories
```
.\seagrid (contains Seagrid application m-files)
.\seagrid\presto (contains a library that Seagrid depends upon)
.\seagrid\test_data (contains test data used in the Seagrid tutorial)
```

You will also find a number of Mex file subdirectories such as
```
.\seagrid\mex_matlab74_win32
.\seagrid\mex_matlab60_linux32
```
that indicate mex files to be used with specific operating system and
Matlab version.

If you don't see your operating system listed, you will need to build
the mex files from source code, which requires both Fortran and C
compilers. If you don't see your version of Matlab, try one from a
previous release. Sometimes they will also work.
