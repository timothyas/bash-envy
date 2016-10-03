function [] = plotAdjMeanByRegion(dirs,mygrid,deseasonFlag,saveFig)
% Plot mean of adjoint sensitivity across globe
% 
%   Inputs: 
%       saveStr : which run to look at
%       dirs : project directory tree
%       mygrid : 
%       deseasonFlag : 1 = take out seasonal signal, 0 = don't
% -------------------------------------------------------------------------

if nargin<1, dirs=establish_samocDirs; end
if nargin<2, establish_mygrid; end
if nargin<3, deseasonFlag=0; end
if nargin<4, saveFig=0; end
runStr = 'region-mean/';
if ~exist([dirs.mat runStr],'dir'), mkdir([dirs.mat runStr]); end
if ~exist([dirs.figs runStr],'dir'), mkdir([dirs.figs runStr]); end

adjField = {'hflux','sflux','tauu','tauv'}; %,'aqh','atemp','swdown','lwdown','precip','runoff','hflux','sflux'};
monthStr = {'june','dec'}; %{'jan','feb','march','april','may','june','july','aug','sept','oct','nov','dec'};
Nadj = length(adjField);
Nmo = length(monthStr);

%% First, establish regional masks
[ msks ] = createRegionMasks( mygrid);


for i = 1:Nadj
    Nt = 241;
    adjMean = zeros(Nmo,Nt);
    adjMeanAcc=zeros(Nmo,Nt);
    adjMeanArc=zeros(Nmo,Nt);
    adjMeanNorth=zeros(Nmo,Nt);
    adjMeanInd=zeros(Nmo,Nt);
    adjMeanAtl=zeros(Nmo,Nt);
    adjMeanPac=zeros(Nmo,Nt);
    for m = 1:Nmo
        adjFile = sprintf('%s%s.240mo/adj_%s.mat',dirs.mat,monthStr{m},adjField{i});
        if exist(adjFile,'file')
            load(adjFile);
            Nt = size(adxx.f1,3);
            adxx = adxx(:,:,1:Nt);
            
            % Global mean
            adjMean(m,:) = computeRegionMean( adxx, mygrid.mskC(:,:,1), mygrid);
            if deseasonFlag, adjMean=removeSeasonality(adjMean); end
            
            % ACC
            adjMeanAcc(m,:) = computeRegionMean( adxx, msks.acc, mygrid );
            if deseasonFlag, adjMeanAcc=removeSeasonality(adjMeanAcc); end
            
            % Arctic
            adjMeanArc(m,:) = computeRegionMean(adxx,msks.arc,mygrid);
            if deseasonFlag, adjMeanArc=removeSeasonality(adjMeanArc); end
            
            % North box
            adjMeanNorth(m,:) = computeRegionMean(adxx,msks.north,mygrid);
            if deseasonFlag, adjMeanNorth=removeSeasonality(adjMeanNorth); end
            
            % Indian Ocean
            adjMeanInd(m,:) = computeRegionMean(adxx,msks.ind,mygrid);
            if deseasonFlag, adjMeanInd=removeSeasonality(adjMeanInd); end
            
            % Atlantic from 60S to 40N
            adjMeanAtl(m,:) = computeRegionMean(adxx,msks.atl,mygrid);
            if deseasonFlag, adjMeanAtl=removeSeasonality(adjMeanAtl); end
            
            % Pacific from 60S
            adjMeanPac(m,:) = computeRegionMean(adxx,msks.pac,mygrid);
            if deseasonFlag, adjMeanPac=removeSeasonality(adjMeanPac); end
        end
    end

    %% Plot all on one page 
    figureL;
%     if deseasonFlag, Nt=Nt-1; end
    t = 1:Nt;
    % Global
    subplot(4,2,1),plot(t, adjMean)    
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    else xlim([1 Nt])
    end
    ylabel('Spatial Mean ( dJ/du(t) )')
    title('Global')
    
    % Arctic
    subplot(4,2,2),plot(t,adjMeanArc )
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    else xlim([1 Nt])
    end
    title('Arctic')

    % North Box 
    subplot(4,2,3),plot(t,adjMeanNorth)
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    else xlim([1 Nt])
    end
    title('Greenland')


    % Atlantic
    subplot(4,2,4), plot(t,adjMeanAtl)
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    else xlim([1 Nt])
    end
    title('Atlantic')

    % Pacific
    subplot(4,2,5), plot(t,adjMeanPac)
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    else xlim([1 Nt])
    end
    ylabel('Spatial Mean ( dJ/du(t) )')
    title('Pacific')

    % Indian
    subplot(4,2,6), plot(t,adjMeanInd)
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    else xlim([1 Nt])
    end
    title('Indian')

    % ACC
    subplot(4,2,7), plot(t,adjMeanAcc)
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    else xlim([1 Nt])
    end
    xlabel('Months')
    title('ACC')
    
    % Text & Legend in bottom right
    subplot(4,2,8), plot(1,1,2,2), axis off
    legend('June dJ/dF','Dec. dJ/dF','Location','West')
    

    set(gcf,'paperorientation','portrait')
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    
    if deseasonFlag
        figFile = sprintf('%s%sadjMean_%s_deseasoned',dirs.figs,runStr,adjField{i});
    else
        figFile = sprintf('%s%sadjMean_%s',dirs.figs,runStr,adjField{i});
    end
    if saveFig, saveas(gcf,figFile,'pdf'); close; end
end
end