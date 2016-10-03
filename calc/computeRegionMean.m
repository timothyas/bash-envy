function [ fldMean ] = computeRegionMean( fld, msk, mygrid)
% Given a field and mask, want to compute a spatial mean over that region.

%% Preliminaries
if isa(fld,'gcmfaces')
    fld = convert2gcmfaces(fld);
end;

if isa(msk,'gcmfaces')
    msk = convert2gcmfaces(msk);
end

sz = size(fld);
if length(sz > 2), Nt = sz(3); 
else Nt = 1; 
end;

%% Get mean
tmp1 = squeeze(nansum(nansum(fld.*msk,1),2));
tmp2 = squeeze(nansum(nansum(msk,1),2));
fldMean = [tmp1/tmp2]';
end