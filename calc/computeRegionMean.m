function [ fldMean ] = computeRegionMean( fld, msk, mygrid)
% Given a field and mask, want to compute a spatial mean over that region.

%% Preliminaries
if isa(fld,'gcmfaces')
    fld = convert2gcmfaces(fld);
end;

sz = size(fld);
if length(sz > 2), Nt = sz(3); 
else Nt = 1; 
end;

%% Get mean
nField = convert2gcmfaces(msk);
tmp1 = squeeze(nansum(nansum(fld,1),2));
tmp2 = squeeze(nansum(nansum(nField,1),2));
fldMean = [tmp1/tmp2]';


end