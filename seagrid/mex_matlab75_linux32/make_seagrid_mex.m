%
% Create mex files.  
%mex mexinside.c;
mex -f ./mexopts.sh -v mexinside.c
%test_mexinside;
%disp ( 'wait for the figure to finish plotting, then hit any key to continue' );
%pause

%mex -v mexrect.F
mex -f ./mexopts.sh -v mexrect.F
%mex -f ./mexrectopts.sh -v mexrect.F
%test_mexrect;
%disp ( 'hit any key to continue' );
%pause

mex -f ./mexopts.sh -v mexsepeli.F
%mex -v mexsepeli.F
%mex -f ./mexsepeliopts.sh -v mexsepeli.F
%test_mexsepeli;


