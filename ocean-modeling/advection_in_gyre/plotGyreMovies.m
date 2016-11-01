%Not necessary on thorneaddpath ../../../MITgcmutils/matlab

adv = [3 30 33 80];

for i = 1:length(adv)

    runDir = sprintf('../../../MITgcm/mysetups/advection_in_gyre/run_%d/',adv(i));
    plotDir = 'plots/';
    if ~exist(plotDir,'dir'),mkdir(plotDir);end;
    
    %% Get the grid and time steps
    iters = grabAllIters( runDir, 'tracers' );
    Nt = length(iters); 
    xc = rdmds([runDir 'XC']);
    yc = rdmds([runDir 'YC']); 
    % dxg = rdmds([runDir 'XG']);
    % dyg = rdmds([runDir 'YG']);
    % drf = rdmds([runDir 'DRF']);
    Nx = size(xc,1);
    Ny = size(xc,2);
    % Nz = size(drf,3);
    % dV = repmat(dxg,[1 1 Nz]).*repmat(dyg,[1 1 Nz]).*repmat(drf,[Nx, Ny, 1]);
    
    %% Grab the tracers
    for tt=1:2
        trac = rdmds([runDir 'tracers'],NaN,'rec',tt);
        
        %% Video making stuff
        vidName = sprintf('%sgyre_adv_trac_%d_%d',plotDir,tt,adv(i));
        vidObj = VideoWriter(vidName);
        set(vidObj,'FrameRate',2);
        open(vidObj);

	cmax=squeeze(max(max(trac(:,:,round(Nt/2)))));
	cmin=squeeze(min(min(trac(:,:,round(Nt/2)))));
        
        ff=figure;
        for n=1:Nt
        	figure(ff),
		[hc hc]=contourf(xc,yc,trac(:,:,n),50);
		set(hc,'linestyle','none')
        	colormap(hot);
		colorbar
		caxis([cmin cmax])
		set(gcf,'paperunits','normalized')
      		set(gcf,'paperposition',[0 0 1 1])
		title(sprintf('Tracer: %d, Adv. Scheme: %d',tt,i))
        	currFrame=getframe(ff);
        	writeVideo(vidObj,currFrame);
        end	
        close(vidObj);
        close(ff);
    end

end
