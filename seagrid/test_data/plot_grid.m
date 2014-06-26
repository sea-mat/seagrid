cd c:/rps/m_cmg/trunk/seagrid/test_data
grd=roms_get_grid('foo.nc')
roms_plot_mesh(grd,1,[1 0 0],'psi')
hold on;
plot(lon_u,lat_u,'kx');
plot(lon_v,lat_v,'bd');
plot(lon_rho,lat_rho,'go');
plot(lon_rho(1,1),lat_rho(1,1),'ks','markersize',12);
plot(lon_v(1,1),lat_v(1,1),'ks','markersize',12);
plot(lon_u(1,1),lat_u(1,1),'ks','markersize',12);
plot(lon_u(2,1),lat_u(2,1),'rs','markersize',12);
title('ROMS Staggered Grid (Arakawa "C")');
