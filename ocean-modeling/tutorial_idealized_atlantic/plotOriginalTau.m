%Not necessary on thorneaddpath ../../../MITgcmutils/matlab
runDir = '../../../MITgcm/mysetups/tutorial_idealized_atlantic/run_eq/';


%% Get the grid and time steps
iters = 8640:8640:864000;
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
T = rdmds([runDir 'Ttave'],NaN);
SST = squeeze(T(:,:,1,:)); % Grab SST

%% Assume constant density and heat capacity for heat content
rho_0 = 1035; 
Cp = 3.985; % kJ/kg*K
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
    saveas(gcf,'GlobalAvg_pTau','pdf')
   
close;

%% Load up last time step snapshots
T = rdmds([runDir 'T'],Inf);
S = rdmds([runDir 'S'],Inf);
u = rdmds([runDir 'U'],Inf);
v = rdmds([runDir 'V'],Inf);
eta=rdmds([runDir 'Eta'],Inf);

figureW;
subplot(2,3,1),contourf(xc,yc,T(:,:,1))
title('Temp. Snapshot: 20m')

subplot(2,4,2),contourf(xc,yc,T(:,:,5))
title('Temp. Snapshot: 1350m')

subplot(2,4,3),contourf(xc,yc,S(:,:,1))
title('Salinity Snapshot: 20m')

subplot(2,4,4),contourf(xc,yc,S(:,:,5))
saveas(gcf,'Ssnap_1350m','pdf')

subplot(2,4,5),contourf(xc,yc,u(:,:,1))
title('Zonal Vel. Snapshot: 20m')

subplot(2,4,6),contourf(xc,yc,u(:,:,5))
title('Zonal Vel. Snapshot: 1350m')

subplot(2,4,7),contourf(xc,yc,v(:,:,1))
title('Meridional Vel. Snapshot: 20m')

subplot(2,4,8),contourf(xc,yc,v(:,:,5))
title('Meridional Vel. Snapshot: 1350m')

set(gcf,'paperorientation','landscape')
set(gcf,'paperunits','normalized')
set(gcf,'paperposition',[0 0 1 1])
saveas(gcf,'vol_snapshots','pdf')
close;


figure;
contourf(xc,yc,eta)
set(gcf,'paperorientation','landscape')
set(gcf,'paperunits','normalized')
set(gcf,'paperposition',[0 0 1 1])
xlabel('Longitude (Deg)')
ylabel('Latitude (Deg)')
title('SSH Snapshot')
saveas(gcf,'EtaSnap','pdf')
close;
