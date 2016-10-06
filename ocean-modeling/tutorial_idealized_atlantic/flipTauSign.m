setupDir = '../../../MITgcm/mysetups/tutorial_idealized_atlantic/';
inputDir = [setupDir 'input_eq/'];

%% Load windx file
windFile = [inputDir 'windx_12x28x7.bin'];
gridSize = [12 28];
windx = readbin(windFile,gridSize,1,'real*8'); 

windx=-windx;

newWindFile = [inputDir 'windx_flip_12x28x7.bin'];
writebin(newWindFile,windx,1,'real*8');

xc=rdmds([inputDir '../run_eq/XC']);
yc=rdmds([inputDir '../run_eq/YC']);

figure
contourf(xc,yc,windx);
title('Flipped Horizontal Wind Field')
set(gcf,'paperorientation','landscape')
set(gcf,'paperunits','normalized')
set(gcf,'paperposition',[0 0 1 1])
saveas(gcf,'neg-wind','pdf')
