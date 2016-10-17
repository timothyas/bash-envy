function [ msks ] = createRegionMasks( mygrid )
% Want to make masks for the following regions: 
% Arctic, ACC, Indian, Pacific Ocean basins &
% "Greenland, north box", and Atlantic - north box
% ------------------------------------------------


%% ACC: Everything south of 60S.
yCond = mygrid.YC < -60;
accMsk= mygrid.mskC(:,:,1).*yCond;
accMsk=accMsk.*mygrid.mskC(:,:,1);
accMsk(isnan(accMsk))=0;

%% Arctic
arcMsk= v4_basin('arct'); %mygrid.mskC(:,:,1).*yCond;
arcMsk=arcMsk.*mygrid.mskC(:,:,1);
arcMsk(isnan(arcMsk))=0;

%% Indian Ocean
indMsk= v4_basin('indExt'); 
indMsk=indMsk.*(mygrid.mskC(:,:,1)-accMsk);
indMsk(isnan(indMsk))=0;

%% Pacific
pacMsk = v4_basin('pacExt');
pacMsk = pacMsk.*(mygrid.mskC(:,:,1) - accMsk);
pacMsk(isnan(pacMsk))=0;

%% North box: 45S - 80N
yCond = mygrid.YC > 45 & mygrid.YC <= 80;
%     xCond = mygrid.XC >= -90 & mygrid.XC <= 10;
atlMsk = v4_basin('atlExt');
northMsk = mygrid.mskC(:,:,1).*yCond.*atlMsk;
northMsk=northMsk.*(mygrid.mskC(:,:,1) - arcMsk);
northMsk(isnan(northMsk))=0;

%% Atlantic without North box 
atlMsk = atlMsk.*(mygrid.mskC(:,:,1) - northMsk - accMsk);
atlMsk(isnan(atlMsk))=0;

%% Czeschel et al's north box
ycond = mygrid.YC > 45 & mygrid 

msks = struct('acc',accMsk,'arc',arcMsk,'ind',indMsk,'pac',pacMsk,'atl',atlMsk,'north',northMsk);
end