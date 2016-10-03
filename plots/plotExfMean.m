function [] = plotExfMean(runStr,dirs,mygrid,deseasonFlag,saveFig)
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

if ~isempty(strfind(runStr,'26N'))
    loadDir = sprintf('%sreconstruct.26N/',dirs.mat);
else
    loadDir = sprintf('%sreconstruct.34S/',dirs.mat);
end

adjField = {'tauu','tauv','hflux','sflux'};
Nadj = length(adjField);

for i = 1:Nadj
    exfFile = sprintf('%sxx_%s.mat',loadDir,adjField{i});	
    if exist(exfFile,'file')
    if deseasonFlag
        figFile = sprintf('%s%sexfMean_%s_deseasoned',dirs.figs,runStr,adjField{i});
    else
        figFile = sprintf('%s%sexfMean_%s',dirs.figs,runStr,adjField{i});
    end
    load(exfFile);
    Nt = size(xx_fld.f1,3);
    xx_fld = xx_fld(:,:,1:Nt);

    % Global mean
    exfMean = computeRegionMean( xx_fld, mygrid.mskC(:,:,1), mygrid);
    if deseasonFlag, exfMean=removeSeasonality(exfMean); end
    
    % ACC
    exfMeanAcc = computeRegionMean( xx_fld, msks.acc, mygrid );
    if deseasonFlag, exfMeanAcc=removeSeasonality(exfMeanAcc); end
    
    % Arctic
    exfMeanArc = computeRegionMean(xx_fld,msks.arc,mygrid);
    if deseasonFlag, exfMeanArc=removeSeasonality(exfMeanArc); end
    
    % North box
    exfMeanNorth = computeRegionMean(xx_fld,msks.north,mygrid);
    if deseasonFlag, exfMeanNorth=removeSeasonality(exfMeanNorth); end
    
    % Indian Ocean
    exfMeanInd = computeRegionMean(xx_fld,msks.ind,mygrid);
    if deseasonFlag, exfMeanInd=removeSeasonality(exfMeanInd); end
    
    % Atlantic from 60S to 40N
    exfMeanAtl = computeRegionMean(xx_fld,msks.atl,mygrid);
    if deseasonFlag, exfMeanAtl=removeSeasonality(exfMeanAtl); end
    
    % Pacific from 60S
    exfMeanPac = computeRegionMean(xx_fld,msks.pac,mygrid);
    if deseasonFlag, exfMeanPac=removeSeasonality(exfMeanPac); end
    
    %% Plot it up 
    figure;
%     if deseasonFlag, Nt=Nt-1; end
    t = 1:Nt;
    plot(t, exfMean,t,exfMeanArc, t, exfMeanNorth, t, exfMeanAtl, ...
         t, exfMeanAcc, t, exfMeanInd, t, exfMeanPac)
    legend('Full Mean','Arctic','North Box','Atlantic 60S-45N','<60S',...
        'Indian >60S','Pacific >60S','location','best')
    xlabel('Months')
    if strcmp(adjField{i},'tauu') || strcmp(adjField{i},'tauv')
        xlim([Nt-36 Nt])
    end
    ylabel('Spatial Mean ( exf(t) )')
    title(sprintf('Mean of %s flux',adjField{i}))
    set(gcf,'paperorientation','landscape')
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    
    if saveFig, saveas(gcf,figFile,'pdf'); end
    close;
    end
end
