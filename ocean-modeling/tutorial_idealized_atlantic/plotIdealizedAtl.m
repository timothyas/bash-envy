%Not necessary on thorneaddpath ../../../MITgcmutils/matlab
runDir = '../../../MITgcm/mysetups/tutorial_idealized_atlantic/run_flip_all/';
plotDir = 'run-flip-all/'
if ~exist(plotDir,'dir'),mkdir(plotDir);end;


%% Get the grid and time steps
if ~isempty(strfind(plotDir,'4f'))
	iters=17280:17280:1728000;
elseif ~isempty(strfind(plotDir,'8f'))
	iters = 34560:34560:3456000;
else 
	iters = 8640:8640:864000;
end
Nt = length(iters); 
xc = rdmds([runDir 'XC']);
yc = rdmds([runDir 'YC']); 
dxg = rdmds([runDir 'XG']);
dyg = rdmds([runDir 'YG']);
drf = rdmds([runDir 'DRF']);
Nx = size(xc,1);
Ny = size(xc,2);
Nz = size(drf,3);
dV = repmat(dxg,[1 1 Nz]).*repmat(dyg,[1 1 Nz]).*repmat(drf,[Nx, Ny, 1]);

%% Grab SST
T = rdmds([runDir 'Ttave'],iters);
SST = squeeze(T(:,:,1,:)); % Grab SST

%% Assume constant density and heat capacity for heat content
rho_0 = 1035; 
Cp = 3.994; % kJ/kg*K from set_defaults
Q = rho_0*Cp* T .* repmat(dV,[1 1 1 Nt]);

%% Compute SST and Q mean globally
SSTavg = zeros(1,Nt);
Qavg = zeros(1,Nt);

surfVol = squeeze(sum(sum(dV(:,:,1),1),2));
totVol = squeeze(sum(sum(sum(dV,1),2),3));
for n=1:Nt
	%T = rdmds([runDir 'Ttave'],iters(n));
	%SST = squeeze(T(:,:,1,:));
	%Q = rho_0*Cp* T .* dV
	SSTavg(n) = squeeze(sum(sum(SST(:,:,n) .* dV(:,:,1),1),2))/surfVol;
  	Qavg(n) = squeeze(sum(sum(sum(Q(:,:,:,n) .* dV,1),2),3))/(totVol);
end

%% Make dem plots
figureW;
subplot(2,1,1),plot(iters,SSTavg)
    xlabel('Hours')
    ylabel('SST Vol. Avg.')
    title('Global Mean SST & Heat Content')
subplot(2,1,2),plot(iters,Qavg)
    xlabel('Hours')
    ylabel('Mean Heat Content')

    set(gcf,'paperorientation','landscape')
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    saveas(gcf,[plotDir 'GlobalAvg_pTau'],'pdf')
   
close;

%% Load up last time step snapshots
T = rdmds([runDir 'T'],Inf);
S = rdmds([runDir 'S'],Inf);
u = rdmds([runDir 'U'],Inf);
v = rdmds([runDir 'V'],Inf); 
w = rdmds([runDir 'W'],Inf);
eta=rdmds([runDir 'Eta'],Inf);
inputDir = [runDir '../input_eq/'];
if ~isempty(strfind(runDir,'flip4'))
	windFile = [inputDir 'windx_flip_4_12x28x7.bin'];
elseif ~isempty(strfind(runDir,'flip'))
	windFile = [inputDir 'windx_flip_12x28x7.bin'];
else
	windFile = [inputDir 'windx_12x28x7.bin'];
end
gridSize = [12 28];
windx = readbin(windFile,gridSize,1,'real*8'); 

figureW;
subplot(2,4,1),contourf(xc,yc,T(:,:,1))
shading flat;
title('T 20m')
colorbar

subplot(2,4,5),contourf(xc,yc,T(:,:,5))
shading flat;
title('T 1350m')
colorbar

sc=34:.1:36;
subplot(2,4,2),contourf(xc,yc,S(:,:,1),sc)
shading flat;
title('S 20m')
colorbar

subplot(2,4,6),contourf(xc,yc,S(:,:,5),sc)
shading flat;
title('S 1350m')
colorbar

subplot(2,4,3),contourf(xc,yc,w(:,:,1))
shading flat
hold on
quiver(xc,yc,u(:,:,1),v(:,:,1),'k')
hold off 
title(sprintf('(U,V): Arrows\nW: Contours 20m'))
colorbar

subplot(2,4,7),contourf(xc,yc,w(:,:,5))
hold on
quiver(xc,yc,u(:,:,5),v(:,:,5),'k')
hold off 
title(sprintf('(U,V): Arrows\nW: Contours 1350m'))
colorbar

subplot(2,4,4), %contourf(xc,yc,w(:,:,1))
contourf(xc,yc,eta)
shading flat;
title('Eta')
colorbar

subplot(2,4,8),% contourf(xc,yc,w(:,:,5))
contourf(xc,yc,windx)
shading flat;
title('U_{wind}')
colorbar

set(gcf,'paperorientation','landscape')
set(gcf,'paperunits','normalized')
set(gcf,'paperposition',[0 0 1 1])
saveas(gcf,[plotDir 'vol_snapshots'],'pdf')
close;


%figure;
%contourf(xc,yc,eta)
%shading flat;
%colorbar
%set(gcf,'paperorientation','landscape')
%set(gcf,'paperunits','normalized')
%set(gcf,'paperposition',[0 0 1 1])
%xlabel('Longitude (Deg)')
%ylabel('Latitude (Deg)')
%title('SSH Snapshot')
%saveas(gcf,[plotDir 'EtaSnap'],'pdf')
%close;
