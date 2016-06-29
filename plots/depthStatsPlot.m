function [] = depthStatsPlot(z,fld,strs)
%% Plot vector as a function of depth with inlet mixed layer
% Take aggregate field and plot mean +/ 1std over top
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

%% Compute mean and std
meanFld = mean(fld,2);
stdFld = std(fld,0,2);

    
%% Plotting
grayCol = [192 192 192]./255;
subplot(4,1,1),plot(fld(1:kind,:),z(1:kind),'color',grayCol)
    hold on
    plot(meanFld(1:kind,:),z(1:kind),'k-')
    plot(meanFld(1:kind,:)+stdFld(1:kind,:),z(1:kind),'k--')
    plot(meanFld(1:kind,:)-stdFld(1:kind,:),z(1:kind),'k--')
    hold off
    set(gca,'ytick',[0:100:500])
    set(gca,'ydir','reverse')
    title(titleStr)
    ylabel(ylbl)
    
subplot(4,1,2:4),plot(fld,z,'color',grayCol)
    hold on
    plot(meanFld,z,'k-')
    plot(meanFld+stdFld,z,'k--')
    plot(meanFld-stdFld,z,'k--')
    hold off
    set(gca,'ydir','reverse')
    ylabel(ylbl)
    xlabel(xlbl)
end