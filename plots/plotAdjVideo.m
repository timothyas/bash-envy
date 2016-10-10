function[ ] = plotAdjVideo(fld, strs, opts, mygrid , exfOpt )
% Make a video through time of mapped field
% Inputs: 
%
%       fld : 3d gcmfaces fld, 3rd dim assumed to be in time
%       strs: data type with fields: 
%           xlbl : x axis label
%           time : unit of time, appended onto xlbl as t-i (time) 
%           clbl : colorbar label 
%           vidName : name of video object
%       opts: data type with fields: 
%           logFld : plot log of field (default 0)
%           caxLim: colorbar scale
%           saveVideo: default = 0
%           figType: long or wide(default)
%       exfOpt: 1 => exf plotting, 0 => adj plotting
% -------------------------------------------------------------------------


% Sift through options
if ~isa(fld,'gcmfaces'), convert2gcmfaces(fld); end

if nargin < 2
    xlbl='';
    time='';
    clbl='';
    vidName = '';
else
    xlbl = strs.xlbl;
    time = strs.time; 
    clbl = strs.clbl;
    vidName = strs.vidName;
end

if nargin < 3
    tLims = [1 12];
    logFld = 1;
    caxLim = 0;
    saveVideo = 0; 
    mmapOpt = 5;
    figType = 'wide';
else
    tLims = opts.tLims; 
    logFld = opts.logFld;
    caxLim = opts.caxLim;
    saveVideo = opts.saveVideo;
    mmapOpt = opts.mmapOpt;
    figType = opts.figType; 
end

if nargin < 4
    establish_mygrid;
end

if nargin<5
    exfOpt=0;
end

% Prepare ranges for logarithmic plotting
if logFld
    [fld] = calcLogField(fld,caxLim,mygrid);
end;
    
% Prep video object
if saveVideo
    vidObj = VideoWriter(vidName); 
    set(vidObj,'FrameRate',2)
    open(vidObj);
end

% Open up a figure
if ~strcmp(figType,'long')
    figureW;
else
    figureL;
end

% Bin for nice plots
% [binFld, colbarticks, colbarlbl, Ntick, cmap] = binForPlotting(fld,caxLim,mygrid);
binFld = fld*10^caxLim; 

caxMax=round(nanmax(abs(fld)));
% caxMin=round(nanmin(fld));

% Do the plotting 
c=gcf();
if exfOpt
    for n=tLims(1):tLims(2)
        
        figure(c),m_map_atl(fld(:,:,n),mmapOpt)%,{'myCaxis',myCaxis});
        hc=colorbar;
        %     set(hc,'ticks',colbarticks,'ticklabels',colbarlbl);
        colormap(redblue);
        caxis([-caxMax caxMax])
        xlabel([xlbl sprintf('t = %d %s',n,time)])
        ylabel(hc,sprintf('x 10^{%d}\n%s',caxLim,clbl),'rotation',0,'position',[4 .2 0]);
        %     keyboard
        if saveVideo
            currFrame=getframe(c);
            writeVideo(vidObj,currFrame);
        end
    end
else
    
    for n=tLims(2):-1:tLims(1)
        
        figure(c),m_map_atl(binFld(:,:,n),mmapOpt)%,{'myCaxis',myCaxis});
        hc=colorbar;
        %     set(hc,'ticks',colbarticks,'ticklabels',colbarlbl);
        colormap(redblue);
        caxis([-1 1])
        xlabel([xlbl sprintf('t-%d %s',tLims(2)-n,time)])
        ylabel(hc,sprintf('x 10^{-%d}\n%s',caxLim,clbl),'rotation',0,'position',[4 .2 0]);
        %     keyboard
        if saveVideo
            currFrame=getframe(c);
            writeVideo(vidObj,currFrame);
        end
    end
end

if saveVideo
    close(vidObj);
    close;
end
end
