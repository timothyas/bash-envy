function [] = doubleDepthPlot(z,fld,strs)
%% Plot vector as a function of depth with inlet mixed layer
% Inputs: 
%    z    : 
%           plot : depth (m) (1d array)
%           pcolor: 2 element cell array with mats of dimension fld
%                   {x-axis mat , y-axis mat (depth)} 
%    fld  : 2d matrix with dim 1 = length(z)
%    strs : plotting labels
%     {1} : xlabel (for field)
%     {2} : ylabel (for depth)
%     {3} : plot title
%     {4} : plot style 'plot' or 'pcolor'
%           if pcolor, z must be cell array with
%   

if nargin<3
    xlbl='';
    ylbl='';
    titleStr='';
    plotStyle='';
else
    xlbl=strs{1};
    ylbl=strs{2};
    titleStr=strs{3};
    if length(strs)<4
        plotStyle='';
    else
        plotStyle=strs{4};
    end
end

%% Plotting
if strcmp(plotStyle,'') || strcmp(plotStyle,'plot')
    
    
    %% Check inputs
if size(fld,1)~=length(z)
    fprintf('Error: fld must have size s.t. dim 1 = length(z)\n')
    return
end
%% Find "ml" depth
Nr = length(z);
z = abs(z);

[mldepth,kind] = min(abs(z - 200));

    
    subplot(4,1,1),plot(fld(1:kind,:),z(1:kind))
    set(gca,'ylim',[0 200])
    set(gca,'ytick',[0:50:200])
    set(gca,'ydir','reverse')
    title(titleStr)
    ylabel(ylbl)
    
    subplot(4,1,2:4),plot(fld,z)
    set(gca,'ydir','reverse')
    ylabel(ylbl)
    xlabel(xlbl)
else
    
%% Find "ml" depth
Nr = size(z{2},1);
z{2} = abs(z{2});

[mldepth,kind] = min(abs(z{2}(1,:) - 200));

    subplot(4,1,1),pcolor(z{1}(:,1:kind),z{2}(:,1:kind),fld(:,1:kind))
    shading interp
    ylim([0 200])
    set(gca,'ytick',[0:50:200])
    set(gca,'ydir','reverse')
    title(titleStr)
    ylabel(ylbl)
    colorbar
    
    subplot(4,1,2:4),pcolor(z{1},z{2},fld)
    shading interp
    set(gca,'ydir','reverse')
    ylabel(ylbl)
    xlabel(xlbl)
    colorbar
end