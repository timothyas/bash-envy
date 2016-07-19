function[ ] = plotVideo(fld, strs, opts, mygrid )
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
%           myCaxis: colorbar limits
%           saveVideo: default = 0
%           figType: long or wide(default)
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
    logFld = 1;
    myCaxis = 'auto';
    saveVideo = 0; 
    figType = 'wide';
else
    logFld = opts.logFld;
    myCaxis = opts.myCaxis;
    saveVideo = opts.saveVideo;
    figType = opts.figType; 
end

if nargin < 4
    establish_mygrid;
end

% Prepare ranges for logarithmic plotting
if logFld
    [fld,~,~,~] = calcLogField(fld,mygrid);
%     fld = 1 + 63*(fld-lmin)/lrng;
%     colbar = [-1, -.1, -.01, 0 , .01, .1, 1];
%     colscale = 1 + 63*(colbar*lmin - lmin)/lrng;
%     myCaxis = [
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

% Prepare ranges
colscale = logspace(-3,0,30)*myCaxis(2);
ctick = [-colscale(end:-1:1), 0, colscale];
Ntick = length(ctick); 
colbarlbl = [-1, -.1, -.01, 0 , .01, .1, 1]*myCaxis(2);
fld=convert2gcmfaces(fld);
binFld = fld;
for i = 1:Ntick
    if i == 1
        bin = fld < ctick(i);
        binFld(bin) = ctick(i);
    elseif i == Ntick
        bin = fld >= ctick(i);
        binFld(bin) = ctick(i);
    else
        bin = fld >= ctick(i-1) & fld < ctick(i);
        binFld(bin) = (ctick(i-1)+ctick(i))*.5;
    end
    
end
binFld=convert2gcmfaces(binFld);
fld=convert2gcmfaces(fld);

% Do the plotting 
c=gcf();
for n=size(fld.f1,3):-1:1
    
    figure(c),m_map_atl(fld(:,:,n),5)%,{'myCaxis',myCaxis});
    hc=colorbar;
    set(hc,'ytick',colbarlbl,'yticklabel',colbarlbl);
    colormap(redblue(Ntick));
    xlabel([xlbl sprintf('t-%d %s',n,time)])
    ylabel(hc,clbl,'rotation',0);
    keyboard
    if saveVideo 
        currFrame=getframe(c);
        writeVideo(vidObj,currFrame); 
    end
end

if saveVideo, close(vidObj); end
close;
end