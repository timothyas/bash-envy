function [] = plotAdjMeanByRegion(dirs,mygrid,deseasonFlag,saveFig)
% Plot mean of adjoint sensitivity across globe
% 
%   Inputs: 
%       saveStr : which run to look at
%       dirs : project directory tree
%       mygrid : 
%       deseasonFlag : 1 = take out seasonal signal, 0 = don't
% -------------------------------------------------------------------------

if nargin<2, dirs=establish_samocDirs; end
if nargin<3, establish_mygrid; end
if nargin<4, deseasonFlag=0; end
if nargin<5, saveFig=0; end
runStr = 'region-mean/';
if ~exist([dirs.mat runStr],'dir'), mkdir([dirs.mat runStr]); end
if ~exist([dirs.figs runStr],'dir'), mkdir([dirs.figs runStr]); end

adjField = {'hflux','sflux'}; %'tauu','tauv','aqh','atemp','swdown','lwdown','precip','runoff','hflux','sflux'};
monthStr = {'jan','feb','march','april','may','june','july','aug','sept','oct','nov','dec'};
Nadj = length(adjField);
Nmo = length(monthStr);


for i = 1:Nadj
    adjMean = zeros(Nmo,240);
    adjMeanAcc=zeros(Nmo,240);
    adjMeanArc=zeros(Nmo,240);
    adjMeanNorth=zeros(Nmo,240);
    adjMeanInd=zeros(Nmo,240);
    adjMeanAtl=zeros(Nmo,240);
    adjMeanPac=zeros(Nmo,240);
    for m = 1:3:Nmo
    adjFile = sprintf('%s%s.240mo/adj_%s.mat',dirs.mat,monthStr{m},adjField{i});	
    if exist(adjFile,'file')    
    load(adjFile);
    Nt = size(adxx.f1,3);
    adxx = adxx(:,:,1:Nt-1);
    Nt = Nt-1;
    
    % Compute spatial RMS of sensitivity
    adxx=convert2gcmfaces(adxx);
    nField=convert2gcmfaces(mygrid.mskC(:,:,1));
    tmp1 = squeeze(nansum(nansum(adxx,1),2));
    tmp2 = squeeze(nansum(nansum(nField,1),2));
    adjMean(m,:) = [tmp1/tmp2]';
    if deseasonFlag, adjMean=removeSeasonality(adjMean); end
    adxx=convert2gcmfaces(adxx);
    
    %% Make a mask remove everything South of 60S.
    yCond = mygrid.YC < -60;
    accMsk= mygrid.mskC(:,:,1).*yCond;
    accMsk=accMsk.*mygrid.mskC(:,:,1);
    accMsk(isnan(accMsk))=0;
    adxxAcc = adxx.*repmat(accMsk,[1 1 Nt]);
    
    adxxAcc=convert2gcmfaces(adxxAcc);
    nField=convert2gcmfaces(accMsk);
    tmp2=squeeze(nansum(nansum(nField,1),2));
    tmp1 = squeeze(nansum(nansum(adxxAcc,1),2));    
    adjMeanAcc(m,:) = [tmp1/tmp2]';
    if deseasonFlag, adjMeanAcc=removeSeasonality(adjMeanAcc); end
    
    %% Now remove Arctic 
    arcMsk= v4_basin('arct'); %mygrid.mskC(:,:,1).*yCond;
    arcMsk=arcMsk.*mygrid.mskC(:,:,1);
    arcMsk(isnan(arcMsk))=0;
    adxxArc = adxx.*repmat(arcMsk,[1 1 Nt]);    

    adxxArc=convert2gcmfaces(adxxArc);
    nField=convert2gcmfaces(arcMsk);
    tmp2=squeeze(nansum(nansum(nField,1),2));
    tmp1 = squeeze(nansum(nansum(adxxArc,1),2));
    adjMeanArc(m,:) = [tmp1/tmp2]';
    if deseasonFlag, adjMeanArc=removeSeasonality(adjMeanArc); end
    
    %% 40N 
    yCond = mygrid.YC > 45 & mygrid.YC <= 80;
%     xCond = mygrid.XC >= -90 & mygrid.XC <= 10;
    atlMsk = v4_basin('atlExt');
    northMsk = mygrid.mskC(:,:,1).*yCond.*atlMsk;
    northMsk=northMsk.*(mygrid.mskC(:,:,1) - arcMsk);
    northMsk(isnan(northMsk))=0;
    adxxNorth = adxx.*repmat(northMsk,[1 1 Nt]);    

    adxxNorth=convert2gcmfaces(adxxNorth);
    nField=convert2gcmfaces(northMsk);
    tmp2=squeeze(nansum(nansum(nField,1),2));
    tmp1 = squeeze(nansum(nansum(adxxNorth,1),2));
    adjMeanNorth(m,:) = [tmp1/tmp2]';
    if deseasonFlag, adjMeanNorth=removeSeasonality(adjMeanNorth); end
    
    %% Indian Ocean
    indMsk= v4_basin('indExt'); %mygrid.mskC(:,:,1).*yCond;
    indMsk=indMsk.*(mygrid.mskC(:,:,1)-accMsk);
    indMsk(isnan(indMsk))=0;
    adxxInd = adxx.*repmat(indMsk,[1 1 Nt]);    

    adxxInd=convert2gcmfaces(adxxInd);
    nField=convert2gcmfaces(indMsk);
    tmp2=squeeze(nansum(nansum(nField,1),2));
    tmp1 = squeeze(nansum(nansum(adxxInd,1),2));
    adjMeanInd(m,:) = [tmp1/tmp2]';
    if deseasonFlag, adjMeanInd=removeSeasonality(adjMeanInd); end
    
    %% Atlantic from 60S to 40N 
    atlMsk = atlMsk.*(mygrid.mskC(:,:,1) - northMsk - accMsk);
    atlMsk(isnan(atlMsk))=0;
    adxxAtl = adxx.*repmat(atlMsk,[1 1 Nt]);
    adxxAtl=convert2gcmfaces(adxxAtl);
    nField=convert2gcmfaces(atlMsk);
    tmp2=squeeze(nansum(nansum(nField,1),2));
    tmp1 = squeeze(nansum(nansum(adxxAtl,1),2));
    adjMeanAtl(m,:) = [tmp1/tmp2]';
    if deseasonFlag, adjMeanAtl=removeSeasonality(adjMeanAtl); end
    
    %% Pacific from 60S
    pacMsk = v4_basin('pacExt');
    pacMsk = pacMsk.*(mygrid.mskC(:,:,1) - accMsk);
    pacMsk(isnan(pacMsk))=0;
    adxxPac = adxx.*repmat(pacMsk,[1 1 Nt]);
    adxxPac=convert2gcmfaces(adxxPac);
    nField=convert2gcmfaces(pacMsk);
    tmp2=squeeze(nansum(nansum(nField,1),2));
    tmp1 = squeeze(nansum(nansum(adxxPac,1),2));
    adjMeanPac(m,:) = [tmp1/tmp2]';
    if deseasonFlag, adjMeanPac=removeSeasonality(adjMeanPac); end
    
    end
    end

    %% Global 
    figure;
%     if deseasonFlag, Nt=Nt-1; end
    t = 1:Nt;
    plot(t, adjMean)    
    xlabel('Months')
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    end
    ylabel('Spatial Mean ( dJ/du(t) )')
    title(sprintf('Mean of %s sens. (global)',adjField{i}))
    set(gcf,'paperorientation','landscape')
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    
    if deseasonFlag
        figFile = sprintf('%s%sadjMean_%s_deseasoned_global',dirs.figs,runStr,adjField{i});
    else
        figFile = sprintf('%s%sadjMean_%s_global',dirs.figs,runStr,adjField{i});
    end
    if saveFig, saveas(gcf,figFile,'pdf'); close; end
    
    
    %% Arctic 
    figure;
%     if deseasonFlag, Nt=Nt-1; end
    t = 1:Nt;
    plot(t, adjMeanArc)    
    xlabel('Months')
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    end
    ylabel('Spatial Mean ( dJ/du(t) )')
    title(sprintf('Mean of %s sens. (Arctic)',adjField{i}))
    set(gcf,'paperorientation','landscape')
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    if deseasonFlag
        figFile = sprintf('%s%sadjMean_%s_deseasoned_arctic',dirs.figs,runStr,adjField{i});
    else
        figFile = sprintf('%s%sadjMean_%s_arctic',dirs.figs,runStr,adjField{i});
    end
    if saveFig, saveas(gcf,figFile,'pdf'); close; end
    
    %% ACC 
    figure;
%     if deseasonFlag, Nt=Nt-1; end
    t = 1:Nt;
    plot(t, adjMeanAcc)    
    xlabel('Months')
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    end
    ylabel('Spatial Mean ( dJ/du(t) )')
    title(sprintf('Mean of %s sens. (ACC)',adjField{i}))
    set(gcf,'paperorientation','landscape')
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    
    if deseasonFlag
        figFile = sprintf('%s%sadjMean_%s_deseasoned_acc',dirs.figs,runStr,adjField{i});
    else
        figFile = sprintf('%s%sadjMean_%s_acc',dirs.figs,runStr,adjField{i});
    end
    if saveFig, saveas(gcf,figFile,'pdf'); close; end
    
    %% North Box 
    figure;
%     if deseasonFlag, Nt=Nt-1; end
    t = 1:Nt;
    plot(t, adjMeanNorth)    
    xlabel('Months')
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    end
    ylabel('Spatial Mean ( dJ/du(t) )')
    title(sprintf('Mean of %s sens. (Greenland Area)',adjField{i}))
    set(gcf,'paperorientation','landscape')
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    if deseasonFlag
        figFile = sprintf('%s%sadjMean_%s_deseasoned_north',dirs.figs,runStr,adjField{i});
    else
        figFile = sprintf('%s%sadjMean_%s_north',dirs.figs,runStr,adjField{i});
    end
    if saveFig, saveas(gcf,figFile,'pdf'); close; end
    
    %% Atlantic 
    figure;
%     if deseasonFlag, Nt=Nt-1; end
    t = 1:Nt;
    plot(t, adjMeanAtl)    
    xlabel('Months')
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    end
    ylabel('Spatial Mean ( dJ/du(t) )')
    title(sprintf('Mean of %s sens. (Atlantic-Greenland)',adjField{i}))
    set(gcf,'paperorientation','landscape')
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    if deseasonFlag
        figFile = sprintf('%s%sadjMean_%s_deseasoned_atl',dirs.figs,runStr,adjField{i});
    else
        figFile = sprintf('%s%sadjMean_%s_atl',dirs.figs,runStr,adjField{i});
    end
    if saveFig, saveas(gcf,figFile,'pdf'); close; end
    
    %% Indian 
    figure;
%     if deseasonFlag, Nt=Nt-1; end
    t = 1:Nt;
    plot(t, adjMeanArc)    
    xlabel('Months')
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    end
    ylabel('Spatial Mean ( dJ/du(t) )')
    title(sprintf('Mean of %s sens. (Indian)',adjField{i}))
    set(gcf,'paperorientation','landscape')
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    if deseasonFlag
        figFile = sprintf('%s%sadjMean_%s_deseasoned_ind',dirs.figs,runStr,adjField{i});
    else
        figFile = sprintf('%s%sadjMean_%s_ind',dirs.figs,runStr,adjField{i});
    end
    if saveFig, saveas(gcf,figFile,'pdf'); close; end
    
    %% Pacific 
    figure;
%     if deseasonFlag, Nt=Nt-1; end
    t = 1:Nt;
    plot(t, adjMeanPac)    
    xlabel('Months')
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    end
    ylabel('Spatial Mean ( dJ/du(t) )')
    title(sprintf('Mean of %s sens. (Pacific)',adjField{i}))
    set(gcf,'paperorientation','landscape')
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    if deseasonFlag
        figFile = sprintf('%s%sadjMean_%s_deseasoned_pac',dirs.figs,runStr,adjField{i});
    else
        figFile = sprintf('%s%sadjMean_%s_pac',dirs.figs,runStr,adjField{i});
    end
    if saveFig, saveas(gcf,figFile,'pdf'); close; end
    
    if saveFig, saveas(gcf,figFile,'pdf'); end
    close;
    end
end
