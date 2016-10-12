setupDir = '../../../MITgcm/mysetups/tutorial_idealized_atlantic/';
inputDir = [setupDir 'input_eq/'];

%% Load windx file and grid for plotting
windFile = [inputDir 'windx_12x28x7.bin'];
gridSize = [12 28];
windx = readbin(windFile,gridSize,1,'real*8'); 
xc=rdmds([inputDir '../run_orig/XC']);
yc=rdmds([inputDir '../run_orig/YC']);

%% Plot original binary file
figure
contourf(xc,yc,windx); shading flat; colorbar;
title('Original Horizontal Wind Field')
set(gcf,'paperorientation','landscape')
set(gcf,'paperunits','normalized')
set(gcf,'paperposition',[0 0 1 1])
saveas(gcf,'orig-tau/orig-wind','pdf')

%% Flip the sign and save
windx=-windx;
newWindFile = [inputDir 'windx_flip_12x28x7.bin'];
writebin(newWindFile,windx,1,'real*8');

%% Plot the flipped version
figure
contourf(xc,yc,windx); shading flat; colorbar
title('Flipped Horizontal Wind Field')
set(gcf,'paperorientation','landscape')
set(gcf,'paperunits','normalized')
set(gcf,'paperposition',[0 0 1 1])
saveas(gcf,'flip-tau/flip-wind','pdf')

%% Now multiply by 4, save and plot
windx=4*windx;
newWindFile = [inputDir 'windx_flip_4_12x28x7.bin'];
writebin(newWindFile,windx,1,'real*8');

figure
contourf(xc,yc,windx); shading flat; colorbar
title('4 x Flipped Horizontal Wind Field')
set(gcf,'paperorientation','landscape')
set(gcf,'paperunits','normalized')
set(gcf,'paperposition',[0 0 1 1])
saveas(gcf,'flip-4-tau/flip-4-wind','pdf')
