#
# mexopts.sh   Shell script for configuring MEX-file creation script,
#               mex.
#
# usage:        Do not call this file directly; it is sourced by the
#               mex shell script.  Modify only if you don't like the
#               defaults after running mex.  No spaces are allowed
#               around the '=' in the variable assignment.
#
# Copyright (c) 1992-95 by The MathWorks, Inc.
# $Revision: 1.32 $  $Date: 1997/04/14 21:00:05 $
#----------------------------------------------------------------------------
#
    case "$Arch" in
        Undetermined)
#----------------------------------------------------------------------------
# Change this line if you need to specify the location of the MATLAB
# root directory.  The cmex script needs to know where to find utility
# routines so that it can determine the architecture; therefore, this
# assignment needs to be done while the architecture is still
# undetermined.
#----------------------------------------------------------------------------
            MATLAB="$MATLAB"
            ;;
        alpha)
#----------------------------------------------------------------------------
            CC='cc'
            CFLAGS='-ieee -std1'
            CLIBS=''
            COPTIMFLAGS='-O2 -DNDEBUG'
            CDEBUGFLAGS='-g'
#
            FC='f77'
            FFLAGS='-shared -align dcommons -r8'
#           FFLAGS=
            FLIBS='-lUfor -lfor -lFutil'
            FOPTIMFLAGS='-O2'
            FDEBUGFLAGS='-g'
#
            LD='ld'
            LDFLAGS="-expect_unresolved '*' -shared -hidden -exported_symbol $ENTRYPOINT -exported_symbol mexVersion"
            LDOPTIMFLAGS=''
            LDDEBUGFLAGS=''
#----------------------------------------------------------------------------
            ;;
        hp700)
#----------------------------------------------------------------------------
            CC='cc'
            CFLAGS='+z -D_HPUX_SOURCE -Aa'
            CLIBS=''
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#
            FC='f77'
            FFLAGS='+z'
            FLIBS=''
            FOPTIMFLAGS='-O'
            FDEBUGFLAGS='-g'
#
            LD='ld'
            LDFLAGS="-b +e $ENTRYPOINT +e mexVersion"
            LDOPTIMFLAGS=''
            LDDEBUGFLAGS=''
#----------------------------------------------------------------------------
            ;;
        ibm_rs)
#----------------------------------------------------------------------------
            CC='cc'
            CFLAGS='-qlanglvl=ansi'
            CLIBS='-lm'
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#
            FC='f77'
            FFLAGS=''
            FLIBS="$MATLAB/extern/lib/ibm_rs/fmex1.o -lm"
            FOPTIMFLAGS='-O'
            FDEBUGFLAGS='-g'
#
            LD='cc'
            LDFLAGS="-bI:$MATLAB/extern/lib/ibm_rs/exp.ibm_rs -bE:$MATLAB/extern/lib/ibm_rs/$MAPFILE -bM:SRE -e $ENTRYPOINT"
            LDOPTIMFLAGS='-s'
            LDDEBUGFLAGS=''
#----------------------------------------------------------------------------
            ;;
        lnx86)
#----------------------------------------------------------------------------
            CC='gcc'
            CFLAGS=''
            CLIBS=''
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#
# Use these flags for using f2c and gcc for Fortan MEX-Files
#
            FC='f2c'
            FOPTIMFLAGS=''
            FFLAGS=''
            FDEBUGFLAGS='-g'
            FLIBS=''
#
# Use these flags for using the Absoft F77 Fortran Compiler
#
        #   FC='f77'
        #   FOPTIMFLAGS=''
        #   FFLAGS='-f -N1 -N9 -N70'
        #   FDEBUGFLAGS='-gg'
        #   FLIBS='-lf77'
#
            LD='gcc'
            LDFLAGS='-shared -rdynamic'
            LDOPTIMFLAGS=''
            LDDEBUGFLAGS=''
#----------------------------------------------------------------------------
            ;;
        sgi)
#----------------------------------------------------------------------------
            CC='cc'
            CFLAGS='-ansi -mips2'
            CLIBS=''
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#
            FC='f77'
            FFLAGS='-r8'
            FLIBS=''
            FOPTIMFLAGS='-O'
            FDEBUGFLAGS='-g'
#
            LD='ld'
            LDFLAGS="-shared -U -Bsymbolic -exported_symbol $ENTRYPOINT -exported_symbol mexVersion"
            LDOPTIMFLAGS=''
            LDDEBUGFLAGS=''
            ;;
#----------------------------------------------------------------------------
        sgi64)
# R8000 only: The default action of mex is to generate full MIPS IV
#             (R8000) instruction set.
#----------------------------------------------------------------------------
            CC='cc'
            CFLAGS='-ansi -mips4 -64'
            CLIBS=''
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#
            FC='f77'
            FFLAGS='-mips4 -64 -r8'
            FLIBS=''
            FOPTIMFLAGS='-O'
            FDEBUGFLAGS='-g'
#
            LD='ld'
            LDFLAGS="-mips4 -64 -shared -U -Bsymbolic -exported_symbol $ENTRYPOINT -exported_symbol mexVersion"
            LDOPTIMFLAGS=''
            LDDEBUGFLAGS=''
            ;;
#----------------------------------------------------------------------------
        sol2)
#----------------------------------------------------------------------------
            CC='cc'
            CFLAGS=''
            CLIBS=''
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#
            FC='f77'
#            FFLAGS='-G -align dcommons -r8'
#
# Added -DPOINTER_INT_4 to make sure that pointers
# on solaris are integer*4 (necessary to make mexsepeli work properly
# -- Rich Signell rsignell@usgs.gov  Feb 17, 2000

             FFLAGS='-G -r8 -DPOINTER_INT_4'
#             FFLAGS='-G -dalign -r8'
#             FFLAGS='-G -dbl'
           
            FLIBS=''
            FOPTIMFLAGS='-O'
            FDEBUGFLAGS='-g'
#
            LD='ld'
            LDFLAGS="-G -M $MATLAB/extern/lib/sol2/$MAPFILE"
            LDOPTIMFLAGS=''
            LDDEBUGFLAGS=''

#----------------------------------------------------------------------------
            ;;
        sun4)
#----------------------------------------------------------------------------
# A dry run of the appropriate compiler is done in the mex script to
# generate the correct library list. Use -v option to see what
# libraries are actually being linked in.
#----------------------------------------------------------------------------
            CC='acc'
            CFLAGS='-DMEXSUN4'
            CLIBS="$MATLAB/extern/lib/sun4/libmex.a -lm"
            COPTIMFLAGS='-O -DNDEBUG'
            CDEBUGFLAGS='-g'
#
            FC='f77'
            FFLAGS=''
            FLIBS="$MATLAB/extern/lib/sun4/libmex.a -lm"
            FOPTIMFLAGS='-O'
            FDEBUGFLAGS='-g'
#
            LD='ld'
            LDFLAGS='-d -r -u _mex_entry_pt -u _mexFunction'
            LDOPTIMFLAGS='-x'
            LDDEBUGFLAGS=''
#----------------------------------------------------------------------------
            ;;
    esac
#############################################################################
#
# Architecture independent lines:
#
#     Set and uncomment any lines which will apply to all architectures.
#
#----------------------------------------------------------------------------
#           CC="$CC"
#           CFLAGS="$CFLAGS"
#           COPTIMFLAGS="$COPTIMFLAGS"
#           CDEBUGFLAGS="$CDEBUGFLAGS"
#           CLIBS="$CLIBS"
#
#           FC="$FC"
#           FFLAGS="$FFLAGS"
#           FOPTIMFLAGS="$FOPTIMFLAGS"
#           FDEBUGFLAGS="$FDEBUGFLAGS"
#           FLIBS="$FLIBS"
#
#           LD="$LD"
#           LDFLAGS="$LDFLAGS"
#           LDOPTIMFLAGS="$LDOPTIMFLAGS"
#           LDDEBUGFLAGS="$LDDEBUGFLAGS"
#----------------------------------------------------------------------------
#############################################################################
#EOF--------------------------------------------------------------------
# diff mexopts.sh(new) mexopts.sh(old)
# date: Mon Aug  4 14:20:36 EDT 1997
# 11c11
# < # $Revision: 1.32 $  $Date: 1997/04/14 21:00:05 $
# ---
# > # $Revision: 1.23 $  $Date: 1996/10/24 18:08:03 $
# 28c28
# <             CFLAGS='-ieee -std1'
# ---
# >             CFLAGS='-ieee_with_no_inexact -std1 -assume noaccuracy_sensitive'
# 30c30
# <             COPTIMFLAGS='-O2 -DNDEBUG'
# ---
# >             COPTIMFLAGS='-O'
# 36c36
# <             FOPTIMFLAGS='-O2'
# ---
# >             FOPTIMFLAGS='-O'
# 50c50
# <             COPTIMFLAGS='-O -DNDEBUG'
# ---
# >             COPTIMFLAGS='-O'
# 70c70
# <             COPTIMFLAGS='-O -DNDEBUG'
# ---
# >             COPTIMFLAGS='-O'
# 80c80
# <             LDFLAGS="-bI:$MATLAB/extern/lib/ibm_rs/exp.ibm_rs -bE:$MATLAB/extern/lib/ibm_rs/$MAPFILE -bM:SRE -e $ENTRYPOINT"
# ---
# >             LDFLAGS="-bI:$MATLAB/extern/lib/ibm_rs/exp.ibm_rs -bM:SRE -e $ENTRYPOINT"
# 90c90
# <             COPTIMFLAGS='-O -DNDEBUG'
# ---
# >             COPTIMFLAGS='-O'
# 105c105
# <         #   FFLAGS='-f -N1 -N9 -N70'
# ---
# >         #   FFLAGS='-f -N9 -N70'
# 118c118
# <             CFLAGS='-ansi -mips2'
# ---
# >             CFLAGS='-ansi'
# 120c120
# <             COPTIMFLAGS='-O -DNDEBUG'
# ---
# >             COPTIMFLAGS='-O'
# 140c140
# <             CFLAGS='-ansi -mips4 -64'
# ---
# >             CFLAGS='-mips4'
# 142c142
# <             COPTIMFLAGS='-O -DNDEBUG'
# ---
# >             COPTIMFLAGS='-O'
# 146c146
# <             FFLAGS='-mips4 -64'
# ---
# >             FFLAGS=''
# 152c152
# <             LDFLAGS="-mips4 -64 -shared -U -Bsymbolic -exported_symbol $ENTRYPOINT -exported_symbol mexVersion"
# ---
# >             LDFLAGS="-mips4 -shared -U -Bsymbolic -exported_symbol $ENTRYPOINT -exported_symbol mexVersion"
# 162c162
# <             COPTIMFLAGS='-O -DNDEBUG'
# ---
# >             COPTIMFLAGS='-O'
# 186c186
# <             COPTIMFLAGS='-O -DNDEBUG'
# ---
# >             COPTIMFLAGS='-O'
# 191c191
# <             FLIBS="$MATLAB/extern/lib/sun4/libmex.a -lm"
# ---
# >             FLIBS='$MATLAB/extern/lib/sun4/libmex.a -lm'
