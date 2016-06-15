function[latVal] = grabLatBand(latMsk, gcmfld)
%% Produces a 2d field of values along a latitude mask
% Restriction: can only work in the Atlantic 
% or can only involve gcmfaces 1 & 5
% Inputs: 
%   latMsk : type=gcmfaces, 2D surface
%            contains 1's for contributing grid cells
%   gcmfld : type=gcmfaces, 3D field
%            contains values desired for midsection returned field
%
% Outputs: 
%   latVal : type=2d matrix
%            dims: [Nx, Nr] Nx: longitudinal basin width, Nr: depth
%-----------------------------------------------------------------------


latMat = convert2gcmfaces(latMsk);

latInd = find(latMat == 1);
Nx = length(latInd);
Nr = size(gcmfld.f1,3);

latVal = zeros(Nx,Nr);

%% First for gcmface 5
NxFace = zeros(2,1);
for iFace = 5:-4:1
    latMat = latMsk{iFace};
    latInd = find(latMat == 1);
    NxFace(iFace) = length(latInd);
for k = 1:Nr
    if iFace == 5
        bigInd = 1;
    else
        bigInd = 1+NxFace(5);
    end
    [li,lj] = ind2sub(size(latMat),latInd);
    for i = 1:length(li)
        latVal(bigInd,k) = gcmfld{iFace}(li(i),lj(i),k);
        bigInd = bigInd + 1;
    end
end
end
latVal = latVal';
end
    
