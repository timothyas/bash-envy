function [] = plotAdjRMS(runStr,dirs,mygrid,deseasonFlag,saveFig)
% Plot RMS of adjoint sensitivity across globe
% 
%   Inputs: 
%       runStr : which run to look at
%       dirs : project directory tree
%       mygrid : 
%       deseasonFlag : 1 = take out seasonal signal, 0 = don't
% -------------------------------------------------------------------------

if nargin<2, dirs=establish_samocDirs; end
if nargin<3, establish_mygrid; end
if nargin<4, deseasonFlag = 0; end
if nargin<5, saveFig = 0; end
if ~exist([dirs.mat runStr],'dir'), mkdir([dirs.mat runStr]); end
if ~exist([dirs.figs runStr],'dir'), mkdir([dirs.figs runStr]); end

adjField = {'tauu','tauv','aqh','atemp','swdown','lwdown','precip','runoff','hflux','sflux'};
Nadj = length(adjField);

for i = 1:Nadj
    adjFile = sprintf('%s%sadj_%s.mat',dirs.mat,runStr,adjField{i});	
    if exist(adjFile,'file')
    if deseasonFlag
        figFile = sprintf('%s%sadjRMS_%s_deseasoned',dirs.figs,runStr,adjField{i});
    else
        figFile = sprintf('%s%sadjRMS_%s',dirs.figs,runStr,adjField{i});
    end
    load(adjFile);
    Nt = size(adxx.f1,3);
    
    % Global mean
    adjRMS = computeRegionMean( adxx, mygrid.mskC(:,:,1), mygrid);
    if deseasonFlag, adjRMS=removeSeasonality(adjRMS); end
    
    % ACC
    adjRMSAcc = computeRegionMean( adxx, msks.acc, mygrid );
    if deseasonFlag, adjRMSAcc=removeSeasonality(adjRMSAcc); end
    
    % Arctic
    adjRMSArc = computeRegionMean(adxx,msks.arc,mygrid);
    if deseasonFlag, adjRMSArc=removeSeasonality(adjRMSArc); end
    
    % North box
    adjRMSNorth = computeRegionMean(adxx,msks.north,mygrid);
    if deseasonFlag, adjRMSNorth=removeSeasonality(adjRMSNorth); end
    
    % Indian Ocean
    adjRMSInd = computeRegionMean(adxx,msks.ind,mygrid);
    if deseasonFlag, adjRMSInd=removeSeasonality(adjRMSInd); end
    
    % Atlantic from 60S to 40N
    adjRMSAtl = computeRegionMean(adxx,msks.atl,mygrid);
    if deseasonFlag, adjRMSAtl=removeSeasonality(adjRMSAtl); end
    
    % Pacific from 60S
    adjRMSPac = computeRegionMean(adxx,msks.pac,mygrid);
    if deseasonFlag, adjRMSPac=removeSeasonality(adjRMSPac); end
    

    %% Plot it up 
    figure;
    t = 1:Nt;
    semilogy(t, adjRMS,t,adjRMSArc, t, adjRMSNorth, t, adjRMSAtl, ...
         t, adjRMSAcc, t, adjRMSInd, t, adjRMSPac)
    legend('Full RMS','Arctic','North Box','Atlantic 60S-45N','<60S',...
        'Indian >60S','Pacific >60S','location','best')
    xlabel('Months')
    ylabel('RMS( dJ/du )')
    title(sprintf('RMS of %s sens.',adjField{i}))
    set(gcf,'paperorientation','landscape')
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    
    if saveFig, saveas(gcf,figFile,'pdf'); end;
    close;
    end
end
