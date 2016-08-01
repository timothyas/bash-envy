function [] = plotAdjMean(runStr,dirs,mygrid,deseasonFlag)
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
if ~exist([dirs.mat runStr],'dir'), mkdir([dirs.mat runStr]); end
if ~exist([dirs.figs runStr],'dir'), mkdir([dirs.figs runStr]); end

adjField = {'tauu','tauv','aqh','atemp','swdown','lwdown','precip','runoff'};
Nadj = length(adjField);

for i = 5:5
    adjFile = sprintf('%s%sadj_%s.mat',dirs.mat,runStr,adjField{i});	
    if deseasonFlag
        figFile = sprintf('%s%sadjMean_%s_deseasoned',dirs.figs,runStr,adjField{i});
    else
        figFile = sprintf('%s%sadjMean_%s',dirs.figs,runStr,adjField{i});
    end
    load(adjFile);
    Nt = size(adxx.f1,3);

    
    % Compute spatial RMS of sensitivity
    adxx=convert2gcmfaces(adxx);
    nField=convert2gcmfaces(mygrid.mskC(:,:,1));
    tmp1 = squeeze(nansum(nansum(adxx,1),2));
    tmp2 = squeeze(nansum(nansum(nField,1),2));
    adjMean = tmp1/tmp2;
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
    adjMeanAcc = tmp1/tmp2;
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
    adjMeanArc = tmp1/tmp2;
    if deseasonFlag, adjMeanArc=removeSeasonality(adjMeanArc); end
    
    %% 40N 
    yCond = mygrid.YC > 45 & mygrid.YC <= 70;
    xCond = mygrid.XC >= -90 & mygrid.XC <= 10;
    atlMsk = v4_basin('atlExt');
    northMsk = mygrid.mskC(:,:,1).*xCond.*yCond.*atlMsk;
    northMsk=northMsk.*(mygrid.mskC(:,:,1) - arcMsk);
    northMsk(isnan(northMsk))=0;
    adxxNorth = adxx.*repmat(northMsk,[1 1 Nt]);    

    adxxNorth=convert2gcmfaces(adxxNorth);
    nField=convert2gcmfaces(northMsk);
    tmp2=squeeze(nansum(nansum(nField,1),2));
    tmp1 = squeeze(nansum(nansum(adxxNorth,1),2));
    adjMeanNorth = tmp1/tmp2;
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
    adjMeanInd = tmp1/tmp2;
    if deseasonFlag, adjMeanInd=removeSeasonality(adjMeanInd); end
    
    %% Atlantic from 60S to 40N 
    atlMsk = atlMsk.*(mygrid.mskC(:,:,1) - northMsk - accMsk);
    atlMsk(isnan(atlMsk))=0;
    adxxAtl = adxx.*repmat(atlMsk,[1 1 Nt]);
    adxxAtl=convert2gcmfaces(adxxAtl);
    nField=convert2gcmfaces(atlMsk);
    tmp2=squeeze(nansum(nansum(nField,1),2));
    tmp1 = squeeze(nansum(nansum(adxxAtl,1),2));
    adjMeanAtl = tmp1/tmp2;
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
    adjMeanPac = tmp1/tmp2;
    if deseasonFlag, adjMeanPac=removeSeasonality(adjMeanPac); end

    %% Plot it up 
    figure;
    if deseasonFlag, Nt=Nt-1; end
    t = 1:Nt;
    plot(t, adjMean,t,adjMeanArc, t, adjMeanNorth, t, adjMeanAtl, ...
         t, adjMeanAcc, t, adjMeanInd, t, adjMeanPac)
    legend('Full RMS','Arctic','Atlantic >40N','Atlantic 60S-40N','<60S',...
        'Indian >60S','Pacific >60S','location','best')
    xlabel('Months')
    ylabel('Spatial Mean ( dJ/du )')
    title(sprintf('Mean of %s sens.',adjField{i}))
    set(gcf,'paperorientation','landscape')
    set(gcf,'paperunits','normalized')
    set(gcf,'paperposition',[0 0 1 1])
    keyboard
    saveas(gcf,figFile,'pdf');
    close;
end
