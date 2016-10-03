function [] = plotAdjMean(runStr,dirs,mygrid,deseasonFlag,saveFig)
% Plot mean of adjoint sensitivity across globe
% 
%   Inputs: 
%       runStr : which run to look at
%       dirs : project directory tree
%       mygrid : 
%       deseasonFlag : 1 = take out seasonal signal, 0 = don't
% -------------------------------------------------------------------------

if nargin<2, dirs=establish_samocDirs; end
if nargin<3, establish_mygrid; end
if nargin<4, deseasonFlag=0; end
if nargin<5, saveFig=0; end
if ~exist([dirs.mat runStr],'dir'), mkdir([dirs.mat runStr]); end
if ~exist([dirs.figs runStr],'dir'), mkdir([dirs.figs runStr]); end

adjField = {'tauu','tauv','aqh','atemp','swdown','lwdown','precip','runoff','hflux','sflux'};
Nadj = length(adjField);

for i = 1:Nadj
    adjFile = sprintf('%s%sadj_%s.mat',dirs.mat,runStr,adjField{i});	
    if exist(adjFile,'file')
    if deseasonFlag
        figFile = sprintf('%s%sadjMean_%s_deseasoned',dirs.figs,runStr,adjField{i});
    else
        figFile = sprintf('%s%sadjMean_%s',dirs.figs,runStr,adjField{i});
    end
    load(adjFile);
    Nt = size(adxx.f1,3);
    adxx = adxx(:,:,1:Nt-1);
    
    % Global mean
    adjMean = computeRegionMean( adxx, mygrid.mskC(:,:,1), mygrid);
    if deseasonFlag, adjMean=removeSeasonality(adjMean); end
    
    % ACC
    adjMeanAcc = computeRegionMean( adxx, msks.acc, mygrid );
    if deseasonFlag, adjMeanAcc=removeSeasonality(adjMeanAcc); end
    
    % Arctic
    adjMeanArc = computeRegionMean(adxx,msks.arc,mygrid);
    if deseasonFlag, adjMeanArc=removeSeasonality(adjMeanArc); end
    
    % North box
    adjMeanNorth = computeRegionMean(adxx,msks.north,mygrid);
    if deseasonFlag, adjMeanNorth=removeSeasonality(adjMeanNorth); end
    
    % Indian Ocean
    adjMeanInd = computeRegionMean(adxx,msks.ind,mygrid);
    if deseasonFlag, adjMeanInd=removeSeasonality(adjMeanInd); end
    
    % Atlantic from 60S to 40N
    adjMeanAtl = computeRegionMean(adxx,msks.atl,mygrid);
    if deseasonFlag, adjMeanAtl=removeSeasonality(adjMeanAtl); end
    
    % Pacific from 60S
    adjMeanPac = computeRegionMean(adxx,msks.pac,mygrid);
    if deseasonFlag, adjMeanPac=removeSeasonality(adjMeanPac); end

    %% Plot it up 
    figure;
%     if deseasonFlag, Nt=Nt-1; end
    t = 1:Nt;
    plot(t, adjMean,t,adjMeanArc, t, adjMeanNorth, t, adjMeanAtl, ...
         t, adjMeanAcc, t, adjMeanInd, t, adjMeanPac)
    legend('Full Mean','Arctic','North Box','Atlantic 60S-45N','<60S',...
        'Indian >60S','Pacific >60S','location','best')
    xlabel('Months')
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    end
    ylabel('Spatial Mean ( dJ/du(t) )')
    title(sprintf('Mean of %s sens.',adjField{i}))
    set(gcf,'paperorientation','landscape')
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    
    if saveFig, saveas(gcf,figFile,'pdf'); end
    close;
    end
end
