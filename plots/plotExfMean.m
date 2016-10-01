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
    xx_fld = xx_fld(:,:,2:Nt);
    Nt = Nt-1;
    
    if strcmp(adjField{i},'hflux') || strcmp(adjField{i},'sflux')
        xx_fld=-xx_fld;
    end

    
    % Compute spatial RMS of sensitivity
    xx_fld=convert2gcmfaces(xx_fld);
    nField=convert2gcmfaces(mygrid.mskC(:,:,1));
    tmp1 = squeeze(nansum(nansum(xx_fld,1),2));
    tmp2 = squeeze(nansum(nansum(nField,1),2));
    exfMean = tmp1/tmp2;
    if deseasonFlag, exfMean=removeSeasonality(exfMean); end
    xx_fld=convert2gcmfaces(xx_fld);
    
    %% Make a mask remove everything South of 60S.
    yCond = mygrid.YC < -60;
    accMsk= mygrid.mskC(:,:,1).*yCond;
    accMsk=accMsk.*mygrid.mskC(:,:,1);
    accMsk(isnan(accMsk))=0;
    xx_fldAcc = xx_fld.*repmat(accMsk,[1 1 Nt]);
    
    xx_fldAcc=convert2gcmfaces(xx_fldAcc);
    nField=convert2gcmfaces(accMsk);
    tmp2=squeeze(nansum(nansum(nField,1),2));
    tmp1 = squeeze(nansum(nansum(xx_fldAcc,1),2));    
    exfMeanAcc = tmp1/tmp2;
    if deseasonFlag, exfMeanAcc=removeSeasonality(exfMeanAcc); end
    
    %% Now remove Arctic 
    arcMsk= v4_basin('arct'); %mygrid.mskC(:,:,1).*yCond;
    arcMsk=arcMsk.*mygrid.mskC(:,:,1);
    arcMsk(isnan(arcMsk))=0;
    xx_fldArc = xx_fld.*repmat(arcMsk,[1 1 Nt]);    

    xx_fldArc=convert2gcmfaces(xx_fldArc);
    nField=convert2gcmfaces(arcMsk);
    tmp2=squeeze(nansum(nansum(nField,1),2));
    tmp1 = squeeze(nansum(nansum(xx_fldArc,1),2));
    exfMeanArc = tmp1/tmp2;
    if deseasonFlag, exfMeanArc=removeSeasonality(exfMeanArc); end
    
    %% 40N 
    yCond = mygrid.YC > 45 & mygrid.YC <= 80;
%     xCond = mygrid.XC >= -90 & mygrid.XC <= 10;
    atlMsk = v4_basin('atlExt');
    northMsk = mygrid.mskC(:,:,1).*yCond.*atlMsk;
    northMsk=northMsk.*(mygrid.mskC(:,:,1) - arcMsk);
    northMsk(isnan(northMsk))=0;
    xx_fldNorth = xx_fld.*repmat(northMsk,[1 1 Nt]);    

    xx_fldNorth=convert2gcmfaces(xx_fldNorth);
    nField=convert2gcmfaces(northMsk);
    tmp2=squeeze(nansum(nansum(nField,1),2));
    tmp1 = squeeze(nansum(nansum(xx_fldNorth,1),2));
    exfMeanNorth = tmp1/tmp2;
    if deseasonFlag, exfMeanNorth=removeSeasonality(exfMeanNorth); end
    
    %% Indian Ocean
    indMsk= v4_basin('indExt'); %mygrid.mskC(:,:,1).*yCond;
    indMsk=indMsk.*(mygrid.mskC(:,:,1)-accMsk);
    indMsk(isnan(indMsk))=0;
    xx_fldInd = xx_fld.*repmat(indMsk,[1 1 Nt]);    

    xx_fldInd=convert2gcmfaces(xx_fldInd);
    nField=convert2gcmfaces(indMsk);
    tmp2=squeeze(nansum(nansum(nField,1),2));
    tmp1 = squeeze(nansum(nansum(xx_fldInd,1),2));
    exfMeanInd = tmp1/tmp2;
    if deseasonFlag, exfMeanInd=removeSeasonality(exfMeanInd); end
    
    %% Atlantic from 60S to 40N 
    atlMsk = atlMsk.*(mygrid.mskC(:,:,1) - northMsk - accMsk);
    atlMsk(isnan(atlMsk))=0;
    xx_fldAtl = xx_fld.*repmat(atlMsk,[1 1 Nt]);
    xx_fldAtl=convert2gcmfaces(xx_fldAtl);
    nField=convert2gcmfaces(atlMsk);
    tmp2=squeeze(nansum(nansum(nField,1),2));
    tmp1 = squeeze(nansum(nansum(xx_fldAtl,1),2));
    exfMeanAtl = tmp1/tmp2;
    if deseasonFlag, exfMeanAtl=removeSeasonality(exfMeanAtl); end
    
    %% Pacific from 60S
    pacMsk = v4_basin('pacExt');
    pacMsk = pacMsk.*(mygrid.mskC(:,:,1) - accMsk);
    pacMsk(isnan(pacMsk))=0;
    xx_fldPac = xx_fld.*repmat(pacMsk,[1 1 Nt]);
    xx_fldPac=convert2gcmfaces(xx_fldPac);
    nField=convert2gcmfaces(pacMsk);
    tmp2=squeeze(nansum(nansum(nField,1),2));
    tmp1 = squeeze(nansum(nansum(xx_fldPac,1),2));
    exfMeanPac = tmp1/tmp2;
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
