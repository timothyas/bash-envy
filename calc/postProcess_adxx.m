function[] = postProcess_adxx(adjField, nFact, X, klev, adjDump, runStr, dirs, mygrid)
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
%       klev : level for 3d terms
%       X={x,xq} : vector for interpolation of time controls
%       adjDump : if 1 (0 is default) then process adj dump files, else
%                 look for adxx files
%       runStr : string for particular run 
%       dirs : project directory tree
%       mygrid : yup
%
% Output:
%
%       adxx : the field as gcmfaces object after post processing
% -------------------------------------------------------------------------

adjLoadDir = [dirs.results runStr];
Nadj = length(adjField);

for i = 1:Nadj
    %% First check if it exists
    adjFile = sprintf('%s%sadj_%s.mat',dirs.mat,runStr,adjField{i});
    
    if ~exist(adjFile,'file')
        %% Load from file
        if ~adjDump
            adxx = read_bin([adjLoadDir 'adxx_' adjField '.0000000012.data']);
        else
            if strcmp(adjField{i},'salt') || strcmp(adjField{i},'theta')
                adxx = rdmds2gcmfaces([adjLoadDir 'ADJustress'],NaN);
                len_adxx = size(adxx.f1,3);
                for n = 1:len_adxx
                    tmp = rdmds2gcmfaces([adjLoadDir 'ADJ' adjField{i}],n);
                    adxx(:,:,n) = tmp(:,:,klev);
                end
            elseif strcmp(adjField{i},'ustress') || strcmp(adjField{i},'vstress')
                if ~exist('adxxU','var')
                    adxxU = rdmds2gcmfaces([adjLoadDir 'ADJustress'],NaN);
                    adxxV = rdmds2gcmfaces([adjLoadDir 'ADJvstress'],NaN);
                    len_adxx = size(adxx.f1,3);
                    for n = 1:len_adxx
                        [adxxU(:,:,n),adxxV(:,:,n)] = calc_UEVNfromUXVY(adxxU(:,:,n),adxxV(:,:,n));
                    end
                    adxx = adxxU;
                else
                    adxx = adxxV;
                end
            else
                adxx = rdmds2gcmfaces([adjLoadDir 'ADJ' adjField{i}],n);
            end
        end
        

        %% Normalize by area or volume
        dxg = mk3D(mygrid.DXG,adxx);
        dyg = mk3D(mygrid.DYG,adxx);
        if strcmp(adjField{i},'salt') || strcmp(adjField{i},'theta')
            if adjDump
                drf = mygrid.DRF(klev);
            else
                drf = mk3D(mygrid.DRF,adxx);
            end
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