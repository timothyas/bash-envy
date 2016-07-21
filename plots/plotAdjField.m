function[ ] = plotAdjField(fld, strs, opts, mygrid )
% Make a figure of a 2d adjoint sensitivity field
% Inputs: 
%
%       fld : 2d gcmfaces fld
%       strs: data type with fields: 
%           xlbl : x axis label
%           clbl : colorbar label 
%           figFile : name of file to be saved
%       opts: data type with fields: 
%           logFld : plot log of field (default 0)
%           caxLim: colorbar scale
%           saveFig: default = 1
%           figType: long or wide(default)
% -------------------------------------------------------------------------


%% Sift through options
if ~isa(fld,'gcmfaces'), convert2gcmfaces(fld); end

if nargin < 2
    xlbl='';
    clbl='';
    figFile = '';
else
    xlbl = strs.xlbl;
    clbl = strs.clbl;
    figFile = strs.figFile;
end

if nargin < 3
    logFld = 1;
    caxLim = 0;
    saveFig = 1; 
    figType = 'wide';
else
    logFld = opts.logFld;
    caxLim = opts.caxLim;
    saveFig = opts.saveFig;
    figType = opts.figType; 
end

if nargin < 4
    establish_mygrid;
end

%% Prepare ranges for logarithmic plotting
if logFld
    [fld] = calcLogField(fld,mygrid);
end;
   

%% Open up a figure
if ~strcmp(figType,'long')
    figureW;
else
    figureL;
end

%% Bin field to nonlinear ticks
% Prepare ranges
% colscale = [.0001:.00005:.001, .0015:.0005:.01, .015:.005:.1, .1:.05:1]*10^-caxLim;
colscale=logspace(-4,0,30);%*10^-caxLim;
ctick = [-colscale(end:-1:1), 0, colscale];
Ntick = length(ctick);
colbarlbl = [-1, -.1, -.01, 0 , .01, .1, 1]; %*10^-caxLim;
fld=convert2gcmfaces(fld)*10^caxLim;
binFld = fld;

% Do the binning
for j = 1:Ntick
    if j == 1
        bin = fld < ctick(j);
        binFld(bin) = ctick(j);
    elseif j == Ntick
        bin = fld >= ctick(j);
        binFld(bin) = ctick(j);
    else
        bin = fld >= ctick(j-1) & fld < ctick(j);
        binFld(bin) = (ctick(j-1)+ctick(j))*.5;
    end
end
binFld=convert2gcmfaces(binFld);
fld=convert2gcmfaces(fld);


%% Do the plotting
c=gcf;
figure(c), m_map_atl(binFld,5)
hc=colorbar;
% set(hc,'ytick',colbarlbl,'yticklabel',colbarlbl);
colormap(redblue(Ntick));
xlabel(xlbl);
ylabel(hc,sprintf('x 10^{-%d}\n%s',caxLim,clbl),'rotation',0,'position',[4 0 0]);
if ~strcmp(figType,'long')
    set(c,'paperorientation','landscape')
    set(c,'paperunits','normalized')
    set(c,'paperposition',[0 0 1 1])
end
if saveFig
        saveas(gcf,figFile,'pdf')
end
close(c);
end
