% Delft2roms
% Converts a Delft3D Grid (with only wet cells defined on corners) 
% to a ROMS grid
%
% Delft3D grid and depth files
d3d_grdfile='teign.grd';
d3d_depfile='teign.dep';
% ROMS NetCDF filename
ROMS_filename='teign.nc';
UTM_zone=30;  % UTM_zone of Delft3d x,y grid coordinates

EARTH_RADIUS_METERS = 6371*1000;   % Default Earth radius used in "seagrid2roms" and "earthdist"
RCF = 180 / pi;

% Read D3D grids
if ~exist('wlgrid')==6   % add delft3d path is 'wlgrid' is not found
addpath c:/delft3d/w32/matlab
end
S=wlgrid('read',d3d_grdfile);
d_delft=wldep('read',d3d_depfile,S);

% can always do eliminate last row/column
% regardless, center or corner
% last row/column always is -999.
d_delft=d_delft(1:end-1,1:end-1); 

% check to see if depths are at rho or psi points
if any(d_delft(isfinite(S.X))==-999.),
    position='center'; 
    disp('Error: Delft2roms handles only Delft3D grids defined on corners');
    return
else
    position='corner';
end

x_psi=fliplr(S.X); % Coordinates of cell corners - psi points (in meters-Easting)
y_psi=fliplr(S.Y); % Coordinates of cell corners - psi points (in meters-Northing)
h_psi=fliplr(d_delft);
h_psi(h_psi==-999)=nan;

%save delft_grid.mat x_psi y_psi h_psi
%load delft_grid.mat x_psi y_psi h_psi
[ny,nx]=size(h_psi);

xnew=x_psi;
ynew=y_psi;
hnew=h_psi;

x1=xnew;y1=ynew;h1=hnew;
x2=xnew;y2=ynew;h2=hnew;
x3=xnew;y3=ynew;h3=hnew;
x4=xnew;y4=ynew;h4=hnew;


for j=1:ny;
    ind=isfinite(hnew(j,:));
    ii=find(diff(ind)==-1);  % land on left, water on right
    if ~isempty(ii),
        x2(j,ii+1)=xnew(j,ii)+(xnew(j,ii)-xnew(j,ii-1));
        y2(j,ii+1)=ynew(j,ii)+(ynew(j,ii)-ynew(j,ii-1));
        h2(j,ii+1)=hnew(j,ii);
    end
    ii=find(diff(ind)==1);  % land on right, water on left
    if ~isempty(ii),
        x1(j,ii)=xnew(j,ii+1)-(xnew(j,ii+2)-xnew(j,ii+1));
        y1(j,ii)=ynew(j,ii+1)-(ynew(j,ii+2)-ynew(j,ii+1));
        h1(j,ii)=hnew(j,ii+1);
    end

end
for i=1:nx;
    ind=isfinite(hnew(:,i));
    ii=find(diff(ind)==-1);  % land on bottom, water on top
    if ~isempty(ii),
        x3(ii+1,i)=xnew(ii,i)+(xnew(ii,i)-xnew(ii-1,i));
        y3(ii+1,i)=ynew(ii,i)+(ynew(ii,i)-ynew(ii-1,i));
        h3(ii+1,i)=hnew(ii,i);
    end
    ii=find(diff(ind)==1);  % land on top, water on bottom
    if ~isempty(ii),
        x4(ii,i)=xnew(ii+1,i)-(xnew(ii+2,i)-xnew(ii+1,i));
        y4(ii,i)=ynew(ii+1,i)-(ynew(ii+2,i)-ynew(ii+1,i));
        h4(ii,i)=hnew(ii+1,i);
    end

end
% average all non-NaN estimates together 
xnew=reshape(gmean([x1(:).'; x2(:).'; x3(:).'; x4(:).']),ny,nx);
ynew=reshape(gmean([y1(:).'; y2(:).'; y3(:).'; y4(:).']),ny,nx);
hnew=reshape(gmean([h1(:).'; h2(:).'; h3(:).'; h4(:).']),ny,nx);

x_rho=nan*ones(ny-1,nx-1);
y_rho=nan*ones(ny-1,nx-1);
h_rho=nan*ones(ny-1,nx-1);


jj=1:ny-1;
ii=1:nx-1;
x_rho=0.25*(xnew(jj,ii)+xnew(jj+1,ii)+xnew(jj,ii+1)+xnew(jj+1,ii+1));
y_rho=0.25*(ynew(jj,ii)+ynew(jj+1,ii)+ynew(jj,ii+1)+ynew(jj+1,ii+1));
h_rho=0.25*(hnew(jj,ii)+hnew(jj+1,ii)+hnew(jj,ii+1)+hnew(jj+1,ii+1));

% if sum of depths at original psi_points is finite, we are at a wet cell
mask_rho=isfinite(h_psi(jj,ii)+h_psi(jj+1,ii)+h_psi(jj,ii+1)+h_psi(jj+1,ii+1));
iwater=find(mask_rho==1);
iland=find(mask_rho==0);

plot(x_psi,y_psi,'k',x_psi.',y_psi.','k',x_rho(iwater),y_rho(iwater),'ro',...
    x_rho(iland),y_rho(iland),'go');dasp
%%
ind=find(isnan(xnew));
xnew(ind)=0;
ynew(ind)=0;
ind=find(isnan(x_rho));
x_rho(ind)=0;
y_rho(ind)=0;
h_rho(ind)=0;

% need to change this if Delft Grid didn't use UTM
[lon_rho,lat_rho]=utm2ll(x_rho,y_rho,UTM_zone);
[lon,lat]=utm2ll(xnew,ynew,UTM_zone);

dx = earthdist(lon(:, 2:end), lat(:, 2:end), lon(:, 1:end-1), lat(:, 1:end-1));
dy = earthdist(lon(2:end, :), lat(2:end, :), lon(1:end-1, :), lat(1:end-1, :));
dlon = diff(lon.').';
dlat = diff(lat.').';
clat = cos(lat / RCF);
clat(:, end) = [];

s.orientation = atan2(dlat, dlon .* clat) * RCF;
s.grids = {xnew/EARTH_RADIUS_METERS, ynew/EARTH_RADIUS_METERS}; 
s.geographic_grids = {lon, lat};
s.geometry = {dx, dy};
s.mask = ~mask_rho;   % s.mask wants 1 for land!
s.gridded_bathymetry = h_rho;
s.projection = 'not from seagrid';  
s.clipping_depths=[min(h_rho(:)) max(h_rho(:))];

save d3d_seagrid.mat s
flipping=0;  % do not invoke flipping in seagrid2roms
seagrid2roms('d3d_seagrid.mat','teign_grid3.nc',...
    'Teignmouth Grid converted from Delft3D','linear',flipping);
