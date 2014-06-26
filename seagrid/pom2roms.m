function []=pom2roms(pomFile,romsFile);
%pomFile='c:\rps\cf\glos\e200912706.out1.nc';
nc=mDataset(pomFile);
lon=nc{'lon'}(:);
lat=nc{'lat'}(:);
depth=nc{'depth'}(:);
close(nc);

depth(depth==0)=nan;
rho.lon=lon;
rho.lat=lat;
rho.depth=depth;
cmd=('save temp.mat rho');
eval(cmd);
mat2roms_rps('temp.mat',romsFile);