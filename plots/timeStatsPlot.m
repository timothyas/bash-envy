function [] = timeStatsPlot(t, fld, strs, flip, plt2stat)
%% Plot vector as a function of time with stats
% Take aggregate field and plot mean +/ 1std over top
% Inputs: 
%    t    : time fld (units) 
%    fld  : case 1: vector - single plot
%           case 2: n rows of vectors to plot
%                   correspond to n plots stacked on top of e/o
%    strs : plotting labels
%     {1} : xlabel (for time)
%     {2} : ylabel (for fld)
%     {3} : plot title
%
%    flip : want y dir flipped? 
%           0 = no for all plots
%           1 = yes for single plot or top plot
%           2 = yes for bottom plot only
%           3 = yes for both plots
%
%    plt2stat : specify 'mean' or 'median'
% -------------------------------------------------------------------------

if size(fld,2) ~= length(t)
    fld = fld';
    if size(fld,2) ~= length(t)
        fprintf('ERROR: fld not same length as time.\n')
        return
    end
end

if size(fld,1) == 1
    
    if nargin<3
        xlbl='';
        ylbl='';
        titleStr='';
    else
        xlbl=strs{1};
        ylbl=strs{2};
        titleStr=strs{3};
    end
    
elseif size(fld,1)==2
    if nargin<3
        xlbl='';
        ylbl='';
        titleStr='';
    else
        xlbl=strs{1};
        ylbl1=strs{2};
        ylbl2=strs{3};
        titleStr=strs{4};
    end
else
    fprintf('Error: Need more subplot capabilities\n')
    return
end

if nargin<4
    flip = 0;
elseif flip<0 || flip>3
    fprintf('ERROR: Flip needs to be 0-3\n')
    return
end
    
if nargin<5
    plt2stat = 'mean';
elseif ~strcmp(plt2stat,'mean') && ~strcmp(plt2stat,'median')
    fprintf('ERROR: 2nd plot option needs to be mean or median\n')
    return
end



%% Set up 
grayCol = [100 100 100]/255;
Nt = t(end)-t(1)+1;


if size(fld,1) == 1
    plot(t,fld,'k'), hold on
    plot(t,mean(fld)*ones(size(t)),'Color',grayCol)
    plot(t,(mean(fld)+std(fld))*ones(size(t)),'--','Color',grayCol);
    plot(t,(mean(fld)-std(fld))*ones(size(t)),'--','Color',grayCol);
    hold off
    xlim([t(1) t(end)])
    xlabel(xlbl);
    ylabel(ylbl);
    title(titleStr)
    if flip ~= 0 
        set(gca,'ydir','reverse')
    end
        
elseif size(fld,1)==2
    subplot(2,1,1),plot(t,fld(1,:),'k')
    hold on
    plot(t,mean(fld(1,:))*ones(size(t)),'Color',grayCol)
    plot(t,(mean(fld(1,:))+std(fld(1,:)))*ones(size(t)),'--','Color',grayCol)
    plot(t,(mean(fld(1,:))-std(fld(1,:)))*ones(size(t)),'--','Color',grayCol)
    hold off
    xlim([t(1) t(end)])
    xlabel(xlbl)
    ylabel(ylbl1)
    title(titleStr)
    if flip == 1 || flip == 3
        set(gca,'ydir','reverse')
    end 
    
    subplot(2,1,2),plot(fld(2,:),'k')
    hold on
    if strcmp(plt2stat,'median')
        plot(1:240,median(fld(2,:))*ones(1,240),'Color',grayCol)
        plot(1:240,(median(fld(2,:))+std(fld(2,:)))*ones(1,240),'--','Color',grayCol)
        plot(1:240,(median(fld(2,:))-std(fld(2,:)))*ones(1,240),'--','Color',grayCol)
    else
        plot(t,mean(fld(2,:))*ones(2,Nt),'Color',grayCol)
        plot(t,(mean(fld(2,:))+std(fld(2,:)))*ones(size(t)),'--','Color',grayCol)
        plot(t,(mean(fld(2,:))-std(fld(2,:)))*ones(size(t)),'--','Color',grayCol)
    end
    hold off
    xlim([t(1) t(end)])
    xlabel(xlbl)
    ylabel(ylbl2)
    if flip == 2 || flip == 3
        set(gca,'ydir','reverse')
    end
end
