function [] = plotAdjRMS(runStr,dirs,mygrid)
% Plot RMS of adjoint sensitivity across globe
% 
%   Inputs: 
%       runStr : which run to look at
%       dirs : project directory tree
%       mygrid : 
% -------------------------------------------------------------------------

if nargin<2, dirs=establish_samocDirs; end
if nargin<3, establish_mygrid; end
if ~exist([dirs.mat runStr],'dir'), mkdir([dirs.mat runStr]); end
if ~exist([dirs.figs runStr],'dir'), mkdir([dirs.figs runStr]); end

adjField = {'tauu','tauv','aqh','atemp','swdown','lwdown','precip','runoff'};
Nadj = length(adjField);
Nt = 240;

for i = 1:Nadj
    adjFile = sprintf('%s%sadj_%s.mat',dirs.mat,runStr,adjField{i});	
    figFile = sprintf('%s%sadjRMS_%s',dirs.figs,runStr,adjField{i});
    load(adjFile);
    adxx=convert2gcmfaces(adxx);
    
    nField=0*adxx(:,:,1); nField=nField+1;
    tmp1 = squeeze(nansum(nansum(adxx.^2,1),2));
    tmp2 = squeeze(nansum(nansum(nField,1),2));
    adjRMS = sqrt(tmp1/tmp2);

    figure;
    plot(1:Nt, adjRMS)
    xlabel('Months')
    ylabel('RMS( dJ/du )')
    title(sprintf('RMS of %s sens.',adjField{i}))
    set(gcf,'paperorientation','landscape')
    saveas(gcf,figFile,'pdf');
    close;
end
