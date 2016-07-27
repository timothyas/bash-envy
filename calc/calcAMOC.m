function [amoc, depthmax, kmax, ovStf] = calcAMOC(slat, velType, mygrid)
% Want to compute SAMOC at some latitude 
%
%  Inputs (optional): 
% 	
%   slat : latitude for computing AMOC 
%	velType : eulerian (default), bolus, or residual velocity fields
%	mygrid 
% 	mydirs : figures, mat, nctiles, ecco dir structure
%
%  Outputs:
%
%	samoc : [1x240] vector with AMOC at 34S using velocity fields specified
%	depthMax : same size, giving max depth at which samoc was computed
%	kmax : gives depth level corresponding to depthmax
%
% ---------------------------------------------------------------------------------

if ~exist('slat','var'), slat=25; fprintf('Defining latitude at 25N\n');end
if nargin<2, velType='eulerian'; end
if nargin<3, establish_mygrid; end

%% Load or compute overturning streamfunction
if ~exist('atlOverturn.mat','file')
    [atlOvStf] = calcAtlOverturn;
else
    load('atlOverturn.mat');
end

%% Grab samoc latitude
iy = find(mygrid.LATS==slat);
if strcmp(velType,'eulerian')
    ovStf = squeeze(atlOvStf(iy,:,:));
elseif strcmp(velType,'bolus')
    ovStf=squeeze(atlBolusOv(iy,:,:));
elseif strcmp(velType,'residual')
    ovStf = squeeze(atlResOv(iy,:,:));
elseif strcmp(velType,'trVolzon')
    ovStf = squeeze(atlTrVolZon(iy,:,:));
else
    fprintf('ERROR: Unrecognized velocity option in computing samoc\n')
end

%% AMOC is integrated (monthly Eulerian mean) transport at maximized depth
kmax = zeros(1,Nt);
amoc = zeros(1,Nt);
depthmax = zeros(1,Nt);
for n = 1:Nt
    [~,kmax(n)] = max(ovStf(:,n));
    amoc(n) = ovStf(kmax(n),n);
    depthmax(n) = abs(mygrid.RF(kmax(n)));
end
end
