@echo off
rem CVF66OPTS.BAT
rem
rem    Compile and link options used for building MEX-files
rem    using the Compaq Visual Fortran compiler version 6.6 
rem
rem    $Revision $  $Date: 2006/01/13 20:56:13 $
rem
rem ********************************************************************
rem General parameters
rem ********************************************************************
set MATLAB=%MATLAB%
set DF_ROOT=c:\program files\microsoft visual studio
set VCDir=%DF_ROOT%\VC98
set MSDevDir=%DF_ROOT%\Common\msdev98
set DFDir=%DF_ROOT%\DF98
set PATH=%MSDevDir%\bin;%DFDir%\BIN;%VCDir%\BIN;%PATH%
set INCLUDE=%DFDir%\INCLUDE;%INCLUDE%;%MATLAB%\extern\include
set LIB=%DFDir%\LIB;%VCDir%\LIB;%LIB%

rem ********************************************************************
rem Compiler parameters
rem ********************************************************************
set COMPILER=df
set COMPFLAGS=/include:"%MATLAB%\extern\include" -c -nokeep -G5 -nologo -DMATLAB_MEX_FILE /fixed
set OPTIMFLAGS=/MD -Ox -DNDEBUG
set DEBUGFLAGS=/MD -Zi
set NAME_OBJECT=/Fo

rem ********************************************************************
rem Linker parameters
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win32\microsoft
set LINKER=link
set LINKFLAGS=/DLL /EXPORT:_MEXFUNCTION@16 /MAP /LIBPATH:"%LIBLOC%" libmx.lib libmex.lib libmat.lib /implib:%LIB_NAME%.lib /NOLOGO
set LINKOPTIMFLAGS=
set LINKDEBUGFLAGS=/debug
set LINK_FILE=
set LINK_LIB=
set NAME_OUTPUT="/out:%OUTDIR%%MEX_NAME%%MEX_EXT%"
set RSP_FILE_INDICATOR=@

rem ********************************************************************
rem Resource compiler parameters
rem ********************************************************************
set RC_COMPILER=rc /fo "%OUTDIR%mexversion.res"
set RC_LINKER=

set POSTLINK_CMDS=del "%OUTDIR%%MEX_NAME%.map"

