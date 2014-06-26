function seagrid2roms_ML(theSeagridFile, theRomsFile,...
    theGridTitle,theInterpMethod,FLIPPING)
% seagrid2roms -- Output ROMS format from SeaGrid file.
%  Usage: seagrid2roms(theSeagridFile, theRomsFile,...
%           theGridTitle, theInterpMethod);
%  Inputs: 
%      theSeagridFile = name of seagrid output file (string)
%      theRomsFile    = name of Roms Grid file to be created (string)
%      theGridTitle   = title of grid (string)
%      theInterpMethod = interp2d method used to double grid (string)
%                        Can be "linear" or "spline" (default is spline)
%                        Use "linear" for seagrid.mat files originating
%                        from Delft grids, which have info only on
%                        the wet cells.
%      FLIPPING = should be 1 (default) for files produced by seagrid
%                 or 0 for files converted from Delft3D grids
%   
%   If '*' is input for theSeagridFile or theRomsFile, dialog boxes are 
%   invoked. 
%
% NOTE: this routine does not employ _FillValue attributes
%  in the output NetCDF variables.
%
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

% Version of 18-Jun-1999 17:11:59.  by Chuck Denham
% Updated    28-Oct-2002 10:12:55.
% Updated    14-Apr-2004 10:12:55.  by Rich Signell
%  -  grid doubling now only in projected coordinate
%  -  distances between grid points now calculated from lon/lat values on spherical earth
%   The default earth radius is
%   assumed to be 6371*1000 meters, the radius for
%   a sphere of equal-volume, the same default as "earthdist.m".


RADIAN_CONVERSION_FACTOR = 180/pi;
EARTH_RADIUS_METERS = 6371*1000;   % Equatorial radius.

if nargin < 1, theSeagridFile = '*.mat'; end
if nargin < 2, theRomsFile = 'roms_grd.nc'; end
if nargin < 3, theGridTitle = char(zeros(1, 128)+abs(' ')); end

if isempty(theSeagridFile) | any(theSeagridFile == '*')
    [f, p] = uigetfile(theSeagridFile, 'Select SeaGrid File:');
    if ~any(f), return, end
    if p(end) ~= filesep, p(end+1) = filesep; end
    theSeagridFile = [p f]
end

if nargin < 2 | isempty(theSeagridFile) | any(theRomsFile == '*')
    [f, p] = uiputfile(theRomsFile, 'Save to Roms File:');
    if ~any(f), return, end
    if p(end) ~= filesep, p(end+1) = filesep; end
    theRomsFile = [p f]
end

disp([' ## SeaGrid Source File  : ' theSeagridFile])
disp([' ## ROMS Destination File: ' theRomsFile])

% Load the SeaGrid file and get parameters.

try
    theSeagridData = load(theSeagridFile, 's');
catch
    disp([' ## Unable to load: "' theSeagridFile '"'])
    return
end

% With grid_x of size [m, n], the grid itself has
%  [m-1, n-1] cells.  The latter size corresponds
%  to the size of the mask and bathymetry.  These
%  cell-centers are called the "rho" points.

s = theSeagridData.s;

grid_x = s.grids{1} * EARTH_RADIUS_METERS;
grid_y = s.grids{2} * EARTH_RADIUS_METERS;
[m, n] = size(grid_x);

geogrid_lon = s.geographic_grids{1};
geogrid_lat = s.geographic_grids{2};
geometry = s.geometry;

mask = s.mask;   % land = 1; water = 0.

if ~isequal(size(mask), size(grid_x)-1)
    if ~isempty(mask)
        disp(' ## Wrong size mask.')
    end
    mask = zeros(m-1, n-1);
end

mask = ~~mask;
land = mask;
water = ~land;

bathymetry = s.gridded_bathymetry;
projection = s.projection;
ang = s.orientation * pi / 180;   % ROMS needs radians.
min_depth = s.clipping_depths(1);
max_depth = s.clipping_depths(2);

% Clip Bathymetry

bathymetry(find(isnan(bathymetry))) = min_depth;
bathymetry(bathymetry<min_depth) = min_depth;
bathymetry(bathymetry>max_depth) = max_depth;

% Double the grid-size before proceeding.
%  The grid-cell-centers are termed the "rho" points.

theInterpFcn = 'interp2';
if nargin<4,
 theInterpMethod = 'spline';
%theInterpMethod = 'linear';
end

grid_x = feval(theInterpFcn, grid_x, 1, theInterpMethod);
grid_y = feval(theInterpFcn, grid_y, 1, theInterpMethod);
geogrid_lon = feval(theInterpFcn, geogrid_lon, 1, theInterpMethod);
geogrid_lat = feval(theInterpFcn, geogrid_lat, 1, theInterpMethod);

% The present size of the grid nodes.

[n, m] = size(grid_x);

% Flip arrays top for bottom.

if (nargin<5)
FLIPPING = 1;  % for files from Seagrid
%FLIPPING = 0; % for files from Delft3D conversion
end

if FLIPPING
    grid_x = flipud(grid_x);
    grid_y = flipud(grid_y);
    geogrid_lon = flipud(geogrid_lon);
    geogrid_lat = flipud(geogrid_lat);
    geometry{1} = flipud(geometry{1});
    geometry{2} = flipud(geometry{2});
    mask = flipud(mask);
    bathymetry = flipud(bathymetry);
    ang = flipud(ang);

end

xl = max(grid_x(:)) - min(grid_x(:));
el = max(grid_y(:)) - min(grid_y(:));

% Create the Roms NetCDF file.


% nc = netcdf(theRomsFile, 'clobber');
ncid = netcdf.create(theRomsFile,'NC_CLOBBER');
if isempty(ncid), return, end

%% Global attributes:

disp(' ## Defining Global Attributes...')

% nc.type = ncchar('Gridpak file');
% nc.gridid = theGridTitle;
% nc.history = ncchar(['Created by "' mfilename '" on ' datestr(now)]);
% 
% nc.CPP_options = ncchar('DCOMPLEX, DBLEPREC, NCARG_32, PLOTS,');
% name(nc.CPP_options, 'CPP-options')

% The SeaGrid is now a full array, whose height
%  and width are odd-valued.  We extract staggered
%  sub-grids for the Roms scheme, ignoring the
%  outermost rows and columns.  Thus, the so-called
%  "rho" points correspond to the even-numbered points
%  in an (i, j) Matlab array.  The "psi" points begin
%  at i = 3 and j = 3.  The whole set is indexed as
%  follows:

% rho (2:2:end-1, 2:2:end-1), i.e. (2:2:m, 2:2:n), etc.
% psi (3:2:end-2, 3:2:end-2)
% u   (2:2:end-1, 3:2:end-2)
% v   (3:2:end-2, 2:2:end-1)

if ~rem(m, 2), m = m-1; end   % m, n must be odd.
if ~rem(n, 2), n = n-1; end

i_rho = 2:2:m-1; j_rho = 2:2:n-1;
i_psi = 3:2:m-2; j_psi = 3:2:n-2;
i_u   = 3:2:m-2; j_u   = 2:2:n-1;
i_v   = 2:2:m-1; j_v   = 3:2:n-2;

% The xi direction (left-right):

Lp = (m-1)/2;   % The rho dimension.
L = Lp-1;       % The psi dimension.

% The eta direction (up-down):

Mp = (n-1)/2;   % The rho dimension.
M = Mp-1;       % The psi dimension.

disp(' ## Defining Dimensions...')

xi_rho_ID = netcdf.defDim(ncid,'xi_rho',Lp);
xi_u_ID = netcdf.defDim(ncid,'xi_u',L);
xi_psi_ID = netcdf.defDim(ncid,'xi_psi',L);
xi_v_ID = netcdf.defDim(ncid,'xi_v',Lp);

eta_rho_ID = netcdf.defDim(ncid,'eta_rho',Mp);
eta_u_ID = netcdf.defDim(ncid,'eta_u',Mp);
eta_v_ID = netcdf.defDim(ncid,'eta_v',M);
eta_psi_ID = netcdf.defDim(ncid,'eta_psi',M);

one_ID = netcdf.defDim(ncid,'one',1);
two_ID = netcdf.defDim(ncid,'two',2);
bath_ID = netcdf.defDim(ncid,'bath',netcdf.getConstant('NC_UNLIMITED'));
% bath_ID = netcdf.defDim(ncid,'bath',0);



%% Variables and attributes:

disp(' ## Defining Variables and Attributes...')

xl_var_ID = netcdf.defVar(ncid,'xl','double',one_ID);
netcdf.putAtt(ncid,xl_var_ID,'long_name','domain length in the XI-direction')
netcdf.putAtt(ncid,xl_var_ID,'units','meter')

el_var_ID = netcdf.defVar(ncid,'el','double',one_ID);
netcdf.putAtt(ncid,el_var_ID,'long_name','domain length in the ETA-direction')
netcdf.putAtt(ncid,el_var_ID,'units','meter')

JPRJ_var_ID = netcdf.defVar(ncid,'JPRJ','char',two_ID);
netcdf.putAtt(ncid,JPRJ_var_ID,'long_name','Map projection type')
netcdf.putAtt(ncid,JPRJ_var_ID,'option_ME_','Mercator')
netcdf.putAtt(ncid,JPRJ_var_ID,'option_ST_','Stereographic')
netcdf.putAtt(ncid,JPRJ_var_ID,'option_LC_','Lambert conformal conic')
netcdf.renameAtt(ncid,JPRJ_var_ID,'option_ME_','option(ME)')
netcdf.renameAtt(ncid,JPRJ_var_ID,'option_ST_','option(ST)')
netcdf.renameAtt(ncid,JPRJ_var_ID,'option_LC_','option(LC)')

PLAT_var_ID = netcdf.defVar(ncid,'PLAT','float',two_ID);
netcdf.putAtt(ncid,PLAT_var_ID,'long_name','Reference latitude(s) for map projection')
netcdf.putAtt(ncid,PLAT_var_ID,'units','degree_north')

PLONG_var_ID = netcdf.defVar(ncid,'PLONG','float',one_ID);
netcdf.putAtt(ncid,PLONG_var_ID,'long_name','Reference longitude for map projection')
netcdf.putAtt(ncid,PLONG_var_ID,'units','degree_east')

ROTA_var_ID = netcdf.defVar(ncid,'ROTA','float',one_ID);
netcdf.putAtt(ncid,ROTA_var_ID,'long_name','Rotation angle for map projection')
netcdf.putAtt(ncid,ROTA_var_ID,'units','degree')

JLTS_var_ID = netcdf.defVar(ncid,'JLTS','char',two_ID);
netcdf.putAtt(ncid,JLTS_var_ID,'long_name','How limits of map are chosen')
netcdf.putAtt(ncid,JLTS_var_ID,'option_CO_','P1, .. P4 define two opposite corners')
netcdf.putAtt(ncid,JLTS_var_ID,'option_MA_','Maximum (whole world)')
netcdf.putAtt(ncid,JLTS_var_ID,'option_AN_','Angles - P1..P4 define angles to edge of domain')
netcdf.putAtt(ncid,JLTS_var_ID,'option_LI_','Limits - P1..P4 define limits in u,v space')
netcdf.renameAtt(ncid,JLTS_var_ID,'option_CO_','option(CO)')
netcdf.renameAtt(ncid,JLTS_var_ID,'option_MA_','option(MA)')
netcdf.renameAtt(ncid,JLTS_var_ID,'option_AN_','option(AN)')
netcdf.renameAtt(ncid,JLTS_var_ID,'option_LI_','option(LI)')

P1_var_ID = netcdf.defVar(ncid,'P1','float',one_ID);
netcdf.putAtt(ncid,P1_var_ID,'long_name','Map limit parameter number 1')

P2_var_ID = netcdf.defVar(ncid,'P2','float',one_ID);
netcdf.putAtt(ncid,P2_var_ID,'long_name','Map limit parameter number 2')

P3_var_ID = netcdf.defVar(ncid,'P3','float',one_ID);
netcdf.putAtt(ncid,P3_var_ID,'long_name','Map limit parameter number 3')

P4_var_ID = netcdf.defVar(ncid,'P4','float',one_ID);
netcdf.putAtt(ncid,P4_var_ID,'long_name','Map limit parameter number 4')

XOFF_var_ID = netcdf.defVar(ncid,'XOFF','float',one_ID);
netcdf.putAtt(ncid,XOFF_var_ID,'long_name','Offset in x direction')
netcdf.putAtt(ncid,XOFF_var_ID,'units','meter')

YOFF_var_ID = netcdf.defVar(ncid,'YOFF','float',one_ID);
netcdf.putAtt(ncid,YOFF_var_ID,'long_name','Offset in y direction')
netcdf.putAtt(ncid,YOFF_var_ID,'units','meter')

depthmin_var_ID = netcdf.defVar(ncid,'depthmin','short',one_ID);
netcdf.putAtt(ncid,depthmin_var_ID,'long_name','Shallow bathymetry clipping depth')
netcdf.putAtt(ncid,depthmin_var_ID,'units','meter')

depthmax_var_ID = netcdf.defVar(ncid,'depthmax','short',one_ID);
netcdf.putAtt(ncid,depthmax_var_ID,'long_name','Deep bathymetry clipping depth')
netcdf.putAtt(ncid,depthmax_var_ID,'units','meter')

spherical_var_ID = netcdf.defVar(ncid,'spherical','char',one_ID);
netcdf.putAtt(ncid,spherical_var_ID,'long_name','Grid type logical switch')
netcdf.putAtt(ncid,spherical_var_ID,'option_T_','spherical')
netcdf.putAtt(ncid,spherical_var_ID,'option_F_','cartesian')
netcdf.renameAtt(ncid,spherical_var_ID,'option_T_','option(T)')
netcdf.renameAtt(ncid,spherical_var_ID,'option_F_','option(F)')

hraw_var_ID = netcdf.defVar(ncid,'hraw','double',[xi_rho_ID eta_rho_ID bath_ID]);
netcdf.putAtt(ncid,hraw_var_ID,'long_name','Working bathymetry at RHO-points')
netcdf.putAtt(ncid,hraw_var_ID,'units','meter')
netcdf.putAtt(ncid,hraw_var_ID,'field','bath, scalar')

h_var_ID = netcdf.defVar(ncid,'h','double',[xi_rho_ID eta_rho_ID]);
netcdf.putAtt(ncid,h_var_ID,'long_name','Final bathymetry at RHO-points')
netcdf.putAtt(ncid,h_var_ID,'units','meter')
netcdf.putAtt(ncid,h_var_ID,'coordinates','lon_rho lat_rho')
netcdf.putAtt(ncid,h_var_ID,'field','bath,scalar')

f_var_ID = netcdf.defVar(ncid,'f','double',[xi_rho_ID eta_rho_ID]);
netcdf.putAtt(ncid,f_var_ID,'long_name','Coriolis parameter at RHO-points')
netcdf.putAtt(ncid,f_var_ID,'units','second-1')
netcdf.putAtt(ncid,f_var_ID,'coordinates','lon_rho lat_rho')
netcdf.putAtt(ncid,f_var_ID,'field','Coriolis,scalar')

pm_var_ID = netcdf.defVar(ncid,'pm','double',[xi_rho_ID eta_rho_ID]);
netcdf.putAtt(ncid,pm_var_ID,'long_name','curvilinear coordinate metric in XI')
netcdf.putAtt(ncid,pm_var_ID,'units','meter-1')
netcdf.putAtt(ncid,pm_var_ID,'field','pm, scalar')

pn_var_ID = netcdf.defVar(ncid,'pn','double',[xi_rho_ID eta_rho_ID]);
netcdf.putAtt(ncid,pn_var_ID,'long_name','curvilinear coordinate metric in ETA')
netcdf.putAtt(ncid,pn_var_ID,'units','meter-1')
netcdf.putAtt(ncid,pn_var_ID,'field','pn, scalar')

dndx_var_ID = netcdf.defVar(ncid,'dndx','double',[xi_rho_ID eta_rho_ID]);
netcdf.putAtt(ncid,dndx_var_ID,'long_name','xi derivative of inverse metric factor pn')
netcdf.putAtt(ncid,dndx_var_ID,'units','meter')
netcdf.putAtt(ncid,dndx_var_ID,'field','dndx, scalar')

dmde_var_ID = netcdf.defVar(ncid,'dmde','double',[xi_rho_ID eta_rho_ID]);
netcdf.putAtt(ncid,dmde_var_ID,'long_name','eta derivative of inverse metric factor pm')
netcdf.putAtt(ncid,dmde_var_ID,'units','meter')
netcdf.putAtt(ncid,dmde_var_ID,'field','dmde, scalar')

x_rho_var_ID = netcdf.defVar(ncid,'x_rho','double',[xi_rho_ID eta_rho_ID]);
netcdf.putAtt(ncid,x_rho_var_ID,'long_name','x location of RHO-points')
netcdf.putAtt(ncid,x_rho_var_ID,'units','meter')

y_rho_var_ID = netcdf.defVar(ncid,'y_rho','double',[xi_rho_ID eta_rho_ID]);
netcdf.putAtt(ncid,y_rho_var_ID,'long_name','y location of RHO-points')
netcdf.putAtt(ncid,y_rho_var_ID,'units','meter')

x_psi_var_ID = netcdf.defVar(ncid,'x_psi','double',[xi_psi_ID eta_psi_ID]);
netcdf.putAtt(ncid,x_psi_var_ID,'long_name','x location of PSI-points')
netcdf.putAtt(ncid,x_psi_var_ID,'units','meter')

y_psi_var_ID = netcdf.defVar(ncid,'y_psi','double',[xi_psi_ID eta_psi_ID]);
netcdf.putAtt(ncid,y_psi_var_ID,'long_name','y location of PSI-points')
netcdf.putAtt(ncid,y_psi_var_ID,'units','meter')

x_u_var_ID = netcdf.defVar(ncid,'x_u','double',[xi_u_ID eta_u_ID]);
netcdf.putAtt(ncid,x_u_var_ID,'long_name','x location of U-points')
netcdf.putAtt(ncid,x_u_var_ID,'units','meter')

y_u_var_ID = netcdf.defVar(ncid,'y_u','double',[xi_u_ID eta_u_ID]);
netcdf.putAtt(ncid,y_u_var_ID,'long_name','y location of U-points')
netcdf.putAtt(ncid,y_u_var_ID,'units','meter')

x_v_var_ID = netcdf.defVar(ncid,'x_v','double',[xi_v_ID eta_v_ID]);
netcdf.putAtt(ncid,x_v_var_ID,'long_name','x location of V-points')
netcdf.putAtt(ncid,x_v_var_ID,'units','meter')

y_v_var_ID = netcdf.defVar(ncid,'y_v','double',[xi_v_ID eta_v_ID]);
netcdf.putAtt(ncid,y_v_var_ID,'long_name','y location of V-points')
netcdf.putAtt(ncid,y_v_var_ID,'units','meter')

lat_rho_var_ID = netcdf.defVar(ncid,'lat_rho','double',[xi_rho_ID eta_rho_ID]);
netcdf.putAtt(ncid,lat_rho_var_ID,'long_name','latitude of RHO-points')
netcdf.putAtt(ncid,lat_rho_var_ID,'units','degree_north')

lon_rho_var_ID = netcdf.defVar(ncid,'lon_rho','double',[xi_rho_ID eta_rho_ID]);
netcdf.putAtt(ncid,lon_rho_var_ID,'long_name','longitude of RHO-points')
netcdf.putAtt(ncid,lon_rho_var_ID,'units','degree_east')

lat_psi_var_ID = netcdf.defVar(ncid,'lat_psi','double',[xi_psi_ID eta_psi_ID]);
netcdf.putAtt(ncid,lat_psi_var_ID,'long_name','latitude of PSI-points')
netcdf.putAtt(ncid,lat_psi_var_ID,'units','degree_north')

lon_psi_var_ID = netcdf.defVar(ncid,'lon_psi','double',[xi_psi_ID eta_psi_ID]);
netcdf.putAtt(ncid,lon_psi_var_ID,'long_name','longitude of PSI-points')
netcdf.putAtt(ncid,lon_psi_var_ID,'units','degree_north')

lat_u_var_ID = netcdf.defVar(ncid,'lat_u','double',[xi_u_ID eta_u_ID]);
netcdf.putAtt(ncid,lat_u_var_ID,'long_name','latitude of U-points')
netcdf.putAtt(ncid,lat_u_var_ID,'units','degree_north')

lon_u_var_ID = netcdf.defVar(ncid,'lon_u','double',[xi_u_ID eta_u_ID]);
netcdf.putAtt(ncid,lon_u_var_ID,'long_name','longitude of U-points')
netcdf.putAtt(ncid,lon_u_var_ID,'units','degree_north')

lat_v_var_ID = netcdf.defVar(ncid,'lat_v','double',[xi_v_ID eta_v_ID]);
netcdf.putAtt(ncid,lat_v_var_ID,'long_name','latitude of V-points')
netcdf.putAtt(ncid,lat_v_var_ID,'units','degree_north')

lon_v_var_ID = netcdf.defVar(ncid,'lon_v','double',[xi_v_ID eta_v_ID]);
netcdf.putAtt(ncid,lon_v_var_ID,'long_name','longitude of V-points')
netcdf.putAtt(ncid,lon_v_var_ID,'units','degree_east')

mask_rho_var_ID = netcdf.defVar(ncid,'mask_rho','double',[xi_rho_ID eta_rho_ID]);
netcdf.putAtt(ncid,mask_rho_var_ID,'long_name','mask on RHO-points')
netcdf.putAtt(ncid,mask_rho_var_ID,'option_0_','land')
netcdf.putAtt(ncid,mask_rho_var_ID,'option_1_','water')
netcdf.renameAtt(ncid,mask_rho_var_ID,'option_0_','option(0)')
netcdf.renameAtt(ncid,mask_rho_var_ID,'option_1_','option(1)')

mask_u_var_ID = netcdf.defVar(ncid,'mask_u','double',[xi_u_ID eta_u_ID]);
netcdf.putAtt(ncid,mask_u_var_ID,'long_name','mask on U-points')
netcdf.putAtt(ncid,mask_u_var_ID,'option_0_','land')
netcdf.putAtt(ncid,mask_u_var_ID,'option_1_','water')
netcdf.renameAtt(ncid,mask_u_var_ID,'option_0_','option(0)')
netcdf.renameAtt(ncid,mask_u_var_ID,'option_1_','option(1)')

mask_v_var_ID = netcdf.defVar(ncid,'mask_v','double',[xi_v_ID eta_v_ID]);
netcdf.putAtt(ncid,mask_v_var_ID,'long_name','mask on V-points')
netcdf.putAtt(ncid,mask_v_var_ID,'option_0_','land')
netcdf.putAtt(ncid,mask_v_var_ID,'option_1_','water')
netcdf.renameAtt(ncid,mask_v_var_ID,'option_0_','option(0)')
netcdf.renameAtt(ncid,mask_v_var_ID,'option_1_','option(1)')

mask_psi_var_ID = netcdf.defVar(ncid,'mask_psi','double',[xi_psi_ID eta_psi_ID]);
netcdf.putAtt(ncid,mask_psi_var_ID,'long_name','mask on PSI-points')
netcdf.putAtt(ncid,mask_psi_var_ID,'option_0_','land')
netcdf.putAtt(ncid,mask_psi_var_ID,'option_1_','water')
netcdf.renameAtt(ncid,mask_psi_var_ID,'option_0_','option(0)')
netcdf.renameAtt(ncid,mask_psi_var_ID,'option_1_','option(1)')

angle_var_ID = netcdf.defVar(ncid,'angle','double',[xi_rho_ID eta_rho_ID]);
netcdf.putAtt(ncid,angle_var_ID,'long_name','angle between xi axis and east')
netcdf.putAtt(ncid,angle_var_ID,'units','radian')

%end define mode
netcdf.endDef(ncid)

% Fill the variables with data.

disp(' ## Filling Variables...')

switch lower(projection)
    case 'mercator'
        theProjection = 'ME';
    case 'stereographic'
        theProjection = 'ST';
    case 'lambert conformal conic'
        theProjection = 'LC';
    otherwise
        theProjection = 'NA'; % not applicable
end

% Fill the variables.

netcdf.putVar(ncid,JPRJ_var_ID,theProjection);
netcdf.putVar(ncid,spherical_var_ID,'T');
netcdf.putVar(ncid,xl_var_ID,xl);
netcdf.putVar(ncid,el_var_ID,el);

f = 2.*7.29e-5.*sin(geogrid_lat(j_rho, i_rho).*pi./180);
f(isnan(f))=0;  % doesn't like f to be NaN
netcdf.putVar(ncid,f_var_ID,f');

netcdf.putVar(ncid,x_rho_var_ID,grid_x(j_rho, i_rho)');
netcdf.putVar(ncid,y_rho_var_ID,grid_y(j_rho, i_rho)');

netcdf.putVar(ncid,x_psi_var_ID,grid_x(j_psi, i_psi)');
netcdf.putVar(ncid,y_psi_var_ID,grid_y(j_psi, i_psi)');

netcdf.putVar(ncid,x_u_var_ID,grid_x(j_u, i_u)');
netcdf.putVar(ncid,y_u_var_ID,grid_y(j_u, i_u)');

netcdf.putVar(ncid,x_v_var_ID,grid_x(j_v, i_v)');
netcdf.putVar(ncid,y_v_var_ID,grid_y(j_v, i_v)');

netcdf.putVar(ncid,lon_rho_var_ID,geogrid_lon(j_rho, i_rho)');
netcdf.putVar(ncid,lat_rho_var_ID,geogrid_lat(j_rho, i_rho)');

netcdf.putVar(ncid,lon_psi_var_ID,geogrid_lon(j_psi, i_psi)');
netcdf.putVar(ncid,lat_psi_var_ID,geogrid_lat(j_psi, i_psi)');

netcdf.putVar(ncid,lon_u_var_ID,geogrid_lon(j_u, i_u)');
netcdf.putVar(ncid,lat_u_var_ID,geogrid_lat(j_u, i_u)');

netcdf.putVar(ncid,lon_v_var_ID,geogrid_lon(j_v, i_v)');
netcdf.putVar(ncid,lat_v_var_ID,geogrid_lat(j_v, i_v)');

if ~isempty(bathymetry)
% netcdf.putVar(ncid,h_var_ID,bathymetry);
netcdf.putVar(ncid,h_var_ID,bathymetry');
end

% Masking.

mask = ~~mask;
land = mask;
water = ~land;

rmask = water;


% Calculate other masking arrays.
umask = zeros(size(rmask));
vmask = zeros(size(rmask));
pmask = zeros(size(rmask));

for i = 2:Lp
    for j = 1:Mp
        umask(j, i-1) = rmask(j, i) * rmask(j, i-1);
    end
end

for i = 1:Lp
    for j = 2:Mp
        vmask(j-1, i) = rmask(j, i) * rmask(j-1, i);
    end
end

for i = 2:Lp
    for j = 2:Mp
        pmask(j-1, i-1) = rmask(j, i) * rmask(j, i-1) * rmask(j-1, i) * rmask(j-1, i-1);
    end
end


netcdf.putVar(ncid,mask_rho_var_ID,uint8(rmask'));

netcdf.putVar(ncid,mask_psi_var_ID,pmask(1:end-1, 1:end-1)');

netcdf.putVar(ncid,mask_u_var_ID,umask(1:end, 1:end-1)');

netcdf.putVar(ncid,mask_v_var_ID,vmask(1:end-1, 1:end)');

% Average angle -- We should do this via (x, y) components.

temp = 0.5*(ang(1:end-1, :) + ang(2:end, :));
ang = zeros(n, m);
ang(2:2:end, 2:2:end) = temp;
ang(isnan(ang))=0; % doesn't like NaN
% nc{'angle'}(:) = ang(j_rho, i_rho);
netcdf.putVar(ncid,angle_var_ID,ang(j_rho, i_rho)');



% Use "geometry" from seagrid file for computation of "pm", "hraw".

% "geometry" contains distances computed from lon and lat in the
% Seagrid routine "dosave.m" using the "earthdist.m" routine, which
% assumes a spherical globe with a radius of 6371 km.

gx = geometry{1};   % Spherical distances in meters.
gy = geometry{2};


sx = 0.5*(gx(1:end-1, :) + gx(2:end, :));
sy = 0.5*(gy(:, 1:end-1) + gy(:, 2:end));

pm = 1 ./ sx;
pn = 1 ./ sy;
hraw = 1 ./ sy;

% pm and hraw cannot be Inf, even if on land, so if values
% are Inf, set to an arbitrary non-zero value
pm(isinf(pm))=0.999e-3;
pn(isinf(pn))=0.999e-3;
hraw(isinf(hraw))=0.999e-3;
pm(isnan(pm))=0.999e-3;
pn(isnan(pn))=0.999e-3;
hraw(isnan(hraw))=0.999e-3;
netcdf.putVar(ncid,pm_var_ID,pm');
netcdf.putVar(ncid,pn_var_ID,pn');

count = [1 Lp Mp];
start = [0 0 0];

hraw_data(:,:,1) = hraw;
netcdf.putVar(ncid,hraw_var_ID,start,count,hraw_data');

dmde = zeros(size(pm));
dndx = zeros(size(hraw));

dmde(2:end-1, :) = 0.5*(1./pm(3:end, :) - 1./pm(1:end-2, :));
dndx(:, 2:end-1) = 0.5*(1./hraw(:, 3:end) - 1./hraw(:, 1:end-2));
dmde(isinf(dmde))=0;
dndx(isinf(dndx))=0;
dmde(isnan(dmde))=0;
dndx(isnan(dndx))=0;
netcdf.putVar(ncid,dmde_var_ID,dmde');

netcdf.putVar(ncid,dndx_var_ID,dndx');


% Final size of file:
% 
% s = size(nc);
% disp([' ## Dimensions: ' int2str(s(1))])
% disp([' ## Variables: ' int2str(s(2))])
% disp([' ## Global Attributes: ' int2str(s(3))])
% disp([' ## Record Dimension: ' name(recdim(nc))])
%    disp([char(13),char(13),char(13)])
    disp(['SCREEN DISPLAY:',char(13)])
    disp('COPY-PASTE the following parameters into your ocean.in file')
    disp('----------------------------------------------------------------------------------------------')
    disp(char(13))
    disp(['    Lm == ' num2str(Lp-2) '         ! Number of I-direction INTERIOR RHO-points'])
    disp(['    Mm == ' num2str(Mp-2) '         ! Number of J-direction INTERIOR RHO-points'])
%     disp(['     N == ' num2str(N) '          ! Number of vertical levels'])
    disp(char(13))
%     disp(['Make sure the Baroclinic time-step (DT) in your ocean.in file is less than: ' num2str(sqrt(((min(min(dx))^2)+(min(min(dy))^2)) / (9.8 * (min(min(h))^2)))) ' seconds'])
    disp('----------------------------------------------------------------------------------------------')

fprintf('\n Done. Grid written to %s!\n', theRomsFile)

netcdf.close(ncid);
