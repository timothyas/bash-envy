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
    logFld = 0;
    caxLim = 0;
    saveFig = 1;
    mmapOpt = 5;
    figType = 'wide';
else
    logFld = opts.logFld;
    caxLim = opts.caxLim;
    saveFig = opts.saveFig;
    mmapOpt = opts.mmapOpt;
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


% Bin for nice plots
[binFld, colbarticks, colbarlbl, Ntick] = binForPlotting(fld,caxLim,mygrid);


%% Do the plotting
c=gcf;
figure(c), m_map_atl(binFld,mmapOpt)
hc=colorbar;
set(hc,'ytick',colbarticks,'yticklabel',colbarlbl);
caxis([-1 1])
colormap(redblue(Ntick));
xlabel(xlbl);
ylabel(hc,sprintf('x 10^{-%d}\n%s',caxLim,clbl),'rotation',0,'position',[4 0.2 0]);
if ~strcmp(figType,'long')
    set(c,'paperorientation','landscape')
    set(c,'paperunits','normalized')
    set(c,'paperposition',[0 0 1 1])
end
if saveFig
        saveas(gcf,figFile,'pdf')
        close(c);
end
end
