%Not necessary on thorneaddpath ../../../MITgcmutils/matlab

adv = [30 33 3 80];
trac=cell(length(adv),1);

for tt = 1:2
for i = 1:length(adv)

    runDir = sprintf('../../../MITgcm/mysetups/advection_in_gyre/run_%d/',adv(i));
    plotDir = 'plots/';
    if ~exist(plotDir,'dir'),mkdir(plotDir);end;
    
    %% Get the grid and time steps
    iters = grabAllIters( runDir, 'tracers' );
    Nt = length(iters); 
    xc = rdmds([runDir 'XC']);
    yc = rdmds([runDir 'YC']); 
    
    %% Grab the tracers
    trac{i} = rdmds([runDir 'tracers'],NaN,'rec',tt);
end
        
    %% Video making stuff
    vidName = sprintf('%sgyre_adv_trac_%d',plotDir,tt);
    vidObj = VideoWriter(vidName);
    set(vidObj,'FrameRate',5);
    open(vidObj);

    %cmax=squeeze(max(max(trac(:,:,round(Nt/2)))));
    %cmin=squeeze(min(min(trac(:,:,round(Nt/2)))));
    
    figureW;
    ff=gcf;
    for n=1:Nt
    	figure(ff),

	subplot(2,2,1),
    	[hc hc]=contourf(xc,yc,trac{1}(:,:,n),50);
    	shading flat;
    	set(hc,'linestyle','none')
    	colormap(hot);
    	colorbar
    	% caxis([cmin cmax])
    	title(sprintf('Adv. Scheme: %d',adv(1)))

	subplot(2,2,2),
    	[hc hc]=contourf(xc,yc,trac{2}(:,:,n),50);
    	shading flat;
    	set(hc,'linestyle','none')
    	colormap(hot);
    	colorbar
    	% caxis([cmin cmax])
    	title(sprintf('Adv. Scheme: %d',adv(2)))

	subplot(2,2,3),
    	[hc hc]=contourf(xc,yc,trac{3}(:,:,n),50);
    	shading flat;
    	set(hc,'linestyle','none')
    	colormap(hot);
    	colorbar
    	% caxis([cmin cmax])
    	title(sprintf('Adv. Scheme: %d',adv(3)))

	subplot(2,2,4),
    	[hc hc]=contourf(xc,yc,trac{4}(:,:,n),50);
    	shading flat;
    	set(hc,'linestyle','none')
    	colormap(hot);
    	colorbar
    	% caxis([cmin cmax])
    	title(sprintf('Adv. Scheme: %d',adv(4)))

    	set(gcf,'paperunits','normalized')
    	set(gcf,'paperposition',[0 0 1 1])
    	currFrame=getframe(ff);
    	writeVideo(vidObj,currFrame);
    end	
    close(vidObj);
    close(ff);
end
