function [] = doubleDepthPlot(z,fld,strs)
%% Plot vector as a function of depth with inlet mixed layer
% Inputs: 
%    z    : depth (m) 
%    fld  : 2d matrix with dim 1 = length(z)
%    strs : plotting labels
%     {1} : xlabel (for field)
%     {2} : ylabel (for depth)
%     {3} : plot title
    

%% Check inputs
if size(fld,1)~=length(z)
    fprintf('Error: fld must have size s.t. dim 1 = length(z)\n')
    return
end

if length(size(fld))>2
    fprintf('Error: Not ready for bigger than 2d mat\n')
    return
end

if nargin<3
    xlbl='';
    ylbl='';
    titleStr='';
else
    xlbl=strs{1};
    ylbl=strs{2};
    titleStr=strs{3};
end

%% Find "ml" depth
Nr = length(z);
z = abs(z);

[mldepth,kind] = min(abs(z - 200));

    
%% Plotting
subplot(4,1,1),plot(fld(1:kind,:),z(1:kind))
    set(gca,'ytick',[0:100:500])
    set(gca,'ydir','reverse')
    title(titleStr)
    ylabel(ylbl)
    
subplot(4,1,2:4),plot(fld,z)
    set(gca,'ydir','reverse')
    ylabel(ylbl)
    xlabel(xlbl)
end