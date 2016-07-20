function[] = postProcess_adxx(adjField, nFact, X, dirs, mygrid)
% Want to post process adxx files as follows: 
%   1. Normalize by area or volume
%   2. Factor (e.g. transport to Sv
%   3. Interpolate results in time
%   4. Save to a *adj_*.mat file
%
% Inputs: 
%
%       adjFields : tauu, tauv, aqh, precip ... 
%       nFact : e.g. 10^-6 for -> Sv
%       X={x,xq} : vector for interpolation of time controls
%       dirs : project directory tree
%       mygrid : yup
%
% Output:
%
%       adxx : the field as gcmfaces object after post processing
% -------------------------------------------------------------------------


Nadj = length(adjField);

for i = 1:Nadj
    %% First check if it exists
    adjFile = sprintf('%s%sadj_%s.mat',dirs.mat,runStr,adjField{i});
    
    if ~exist(adjFile,'file')
        %% Load from file
        adxx = read_bin([adjLoadDir 'adxx_' adjField '.0000000012.data']);

        %% Normalize by area or volume
        dxg = mk3D(mygrid.DXG,adxx);
        dyg = mk3D(mygrid.DYG,adxx);
        if strcmp(adjField{i},'salt') || strcmp(adjField{i},'theta')
            drf = mk3D(mygrid.DRF,adxx);
            adxx = adxx./dxg./dyg ./ drf;
        else
            adxx = adxx./dxg./dyg;
        end        

        %% Factor 
        adxx = adxx*nFact;
    
        %% Interpolate along 3rd dim
        if X==0 || strcmp(adjField{i},'salt') || strcmp(adjField{i},'theta')
            fprintf('** adxx post process: no interpolation\n');
        else
            adxx = gcmfaces_interp_1d(3, X{1}, adxx, X{2});
        end
        
        %% Save as mat file
        save(adjFile,'adxx')
    end
end
end