function [] = plotadx(runStr,projectStr,mygrid)
%% Plot adjoint sensitivities as a movie
%
%   Inputs: 
%       runStr : describes save dir e.g. dec.240mo, 12mo, 
%       projectStr : 'samoc' or 'rapid' 
%       mygrid : ...
% -------------------------------------------------------------------------

%% Establish directories
if ~exist('runStr','var')
    fprintf('ERROR: need to define runStr (e.g. dec.240mo/\n');
    return
end
if strcmp(projectStr,'samoc')
    dirs=establish_samocDirs;
    fprintf('** Change directory to ... /gcm-contrib/samoc/\n')
    mmapOpt = 5; 
elseif strcmp(projectStr,'rapid')
    dirs=establish_rapidDirs;
    fprintf('** Change directory to ... /gcm-contrib/rapid/\n')
    mmapOpt = 6; 
else
    fprintf('Project string not recognized ... ')
end

if nargin<3
    establish_mygrid;
end

%% Preliminaries
if ~exist([dirs.mat runStr],'dir'), mkdir([dirs.mat runStr]); end
if ~exist([dirs.figs runStr],'dir'), mkdir([dirs.figs runStr]); end

%% Prepare fields
% Omitting theta and salinity right now
adjField = {'tauu','tauv','aqh','atemp','swdown','lwdown','precip','runoff'};
if ~isempty(strfind(runStr,'366day'))
    caxLim = [13, 13, 13, 17, 18, 18, 9, 9, 4, 4];
elseif ~isempty(strfind(runStr,'mo'))
%     caxLim = [12, 12, 12, 16, 17, 17, 7, 7, 4, 4];
    caxLim = [2, 2, 2, 6, 7, 7, -2, -2, 4, 4];
elseif ~isempty(strfind(runStr,'five-day'))
    caxLim = [13, 13, 13, 17, 18, 18, 8, 8, 14, 14];
end

cunits = {sprintf('Sv/\n[N/m^2]'),sprintf('Sv/\n[N/m^2]'),sprintf('Sv/\n[kg/kg]'),sprintf('Sv/K'),...
          sprintf('Sv/\n[W/m^2]'),sprintf('Sv/\n[W/m^2]'),sprintf('Sv/\n[m/s]'),sprintf('Sv/\n[m/s]'),...
          sprintf('Sv/psu'),sprintf('Sv/K')};
      
tLims = {[204 240], [204 240], [1 240], [1 240], [1 240], [1 240], [1 240], [1 240]};
Nadj = length(adjField);
klev = 5; 

%% Make sure post processing is done
if ~isempty(strfind(runStr,'240mo'))
%     Xinterp = {[0.5:240.5]/240, [0.5:239.5]/240}; 
    Xinterp = {0,0};

elseif ~isempty(strfind(runStr,'12mo'))
    Xinterp = {[0.5:12.5]/12, [0.5:11.5]/12};
else
    Xinterp = {0,0};
end
    
if ~isempty(strfind(runStr,'five-day')), adjDump=1; else adjDump=0; end
postProcess_adxx(adjField,10^-6, Xinterp, klev, adjDump, runStr, dirs, mygrid);

%% Plot and save at various time steps
for i = 1:Nadj
    adjFile = sprintf('%s%sadj_%s.mat',dirs.mat,runStr,adjField{i});
    load(adjFile);
    
    if ~adjDump && (strcmp(adjField{i},'salt') || strcmp(adjField{i},'theta'))
        %% Figure of field at klev for 3d constant fields
        figFile = sprintf('%s%sadj_%s',dirs.figs,runStr,adjField{i});
        
        strs = struct(...
            'xlbl',sprintf('J() = time mean of final month AMOC\nSensitivity to %s, 50m depth',adjField{i}),...
            'clbl',cunits{i},...
            'figFile',figFile);
        opts = struct(...
            'logFld',0,...
            'caxLim',caxLim(i),...
            'saveFig',1,...
            'mmapOpt',mmapOpt,...
            'figType','wide');
        
        plotAdjField(adxx(:,:,klev),strs,opts,mygrid);
    else
        %% Video for time varying controls
        if ~isempty(strfind(runStr,'366day'))
            adxx = gcmfaces_interp_1d(3,[.5:365.5]/366,adxx,[.5:51.5]/52);
        end
        if ~isempty(strfind(runStr,'mo')), tt='months';
        elseif ~isempty(strfind(runStr,'366day')),tt='days';
        elseif ~isempty(strfind(runStr,'five-day')),tt='hrs';
        end
        strs = struct(...
            'xlbl',sprintf('J() = time mean of final month AMOC\nSensitivity to %s ',adjField{i}), ...
            'time',tt,...
            'clbl',cunits{i},...
            'vidName',sprintf('%s%sadj_%s',dirs.figs,runStr,adjField{i}));
        opts = struct(...
            'tLims',tLims{i},...
            'logFld',0,...
            'caxLim',caxLim(i),...
            'saveVideo',1,...
            'mmapOpt',mmapOpt,...
            'figType','wide');

            plotAdjVideo(adxx,strs,opts,mygrid);
    end
end
end
