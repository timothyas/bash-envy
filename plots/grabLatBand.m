function[latVal] = grabLatBand(lineMsk, ufld, vfld)
%% Produces a 2d field of values along a latitude mask
% Restriction: can only work in the Atlantic 
% or can only involve gcmfaces 1 & 5
% Inputs: 
%   lineMsk : type= field with gcmfaces objects mskWedge & mskSedge
%            should be from LAT_MASKS or created by gcmfaces_lines_transp()
%
%   ufld/vfld : type=gcmfaces, 3D field
%            contains values desired for midsection returned field
%
% Outputs: 
%   latVal : type=2d matrix
%            dims: [Nx, Nr] Nx: longitudinal basin width, Nr: depth
%-----------------------------------------------------------------------

mskW = convert2array(lineMsk.mskWedge);
mskS = convert2array(lineMsk.mskSedge); 

mskW(isnan(mskW))=0;
mskS(isnan(mskS))=0;

latIndW = find(mskW~=0);
latIndS = find(mskS~=0);

Nx = length(latIndW)+length(latIndS);
Nr = size(ufld.f1,3);

latVal = zeros(Nx,Nr);

%% First for gcmface 5
NxFaceW = zeros(5,1);
NxFaceS = zeros(5,1);
for iFace = 5:-4:1
    
    mskW = lineMsk.mskWedge{iFace};
    mskS = lineMsk.mskSedge{iFace};
    
    mskW(isnan(mskW))=0;
    mskS(isnan(mskS))=0;
    
    latIndW = find(mskW~=0);
    latIndS = find(mskS~=0);

    NxFaceW(iFace)=length(latIndW);
    NxFaceS(iFace)=length(latIndS);
    
for k = 1:Nr
    %% West component
    if iFace == 5
        bigInd = 1;
    else
        bigInd = 1+NxFaceW(5);
    end
    [li,lj] = ind2sub(size(mskW),latIndW);
    for i = 1:length(li)
        latVal(bigInd,k) = ufld{iFace}(li(i),lj(i),k).*mskW(li(i),lj(i));
        bigInd = bigInd + 1;
    end
    %% South component
    if iFace == 5
        bigInd = 1;
    else
        bigInd = 1+NxFaceW(5);
    end
    [li,lj] = ind2sub(size(mskS),latIndS);
    for i = 1:length(li)
        latVal(bigInd,k) = vfld{iFace}(li(i),lj(i),k).*mskS(li(i),lj(i));
        bigInd = bigInd + 1;
    end
end
end
latVal = latVal';
end
    
