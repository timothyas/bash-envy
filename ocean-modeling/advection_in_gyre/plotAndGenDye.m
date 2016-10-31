%% My dirs
plotDir = 'plots/';
if ~exist(plotDir,'dir'), mkdir(plotDir); end;

%% Run dirs
setupDir = '../../../MITgcm/mysetups/advection_in_gyre/';
inputDir = [setupDir 'input/'];

%% As per gendata.m
ieee='b'; accuracy='real*8';
nx=60; ny=60;
gridSize=[60 60];
if exist([setupDir 'run/XC.data'],'file')
	xc=rdmds([inputDir '../run/XC']);
	yc=rdmds([inputDir '../run/YC']);
else
	[xc,yc] = meshgrid(1:nx,1:ny);
end

%% Load existing dye (TRAC01) and plot
fName = [inputDir 'dye.bin'];
fid=fopen(fName,'r',ieee);
dye1 = fread(fid,gridSize,accuracy); 
fclose(fid);

%% Plot original binary file
figure
contourf(xc,yc,dye1); shading flat; colorbar;
title('Original Dye (TRAC01, t=t0)')
set(gcf,'paperorientation','landscape')
set(gcf,'paperunits','normalized')
set(gcf,'paperposition',[0 0 1 1])
saveas(gcf,[plotDir 'trac01_t0'],'pdf')

%% Generate new dye
dye2 = zeros(gridsize);
dye2(30,15) = 1;
fName = [inputDir 'dye2.bin'];
fid=fopen(fName,'w',ieee);
fwrite(fid,dye2,accuracy);
fclose(fid);

%% Plot the second (TRAC02) dye
figure
contourf(xc,yc,dye2); shading flat; colorbar
title('New Dye (TRAC02, t=t0)')
set(gcf,'paperorientation','landscape')
set(gcf,'paperunits','normalized')
set(gcf,'paperposition',[0 0 1 1])
saveas(gcf,[plotDir 'trac02_t0'],'pdf')
