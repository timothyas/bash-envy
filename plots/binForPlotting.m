function [ binFld, colbarticks, colbarlbl, Ntick, cmap2 ] = binForPlotting(fld,caxLim,mygrid) 


% Prepare ranges
vv=.25:.25:1;
colscale = [10^-3*vv 10^-2*vv 10^-1*vv 1*vv];
ctick = [-colscale(end:-1:1), 0 colscale];
dcx = min(diff(ctick));
y=-1:dcx:1;
Ntick = length(ctick); 
cmap = colormap(redblue(Ntick));
cmap2 = [interp1(ctick(:),cmap(:,1),y(:)),...
        interp1(ctick(:),cmap(:,2),y(:)), ...
        interp1(ctick(:),cmap(:,3),y(:))];

   
if Ntick==33
    colbarticks = [-1:.25:-.25 0 0.25:.25:1]; %[-1:8/Ntick:-8/Ntick 0 9/Ntick:8/Ntick:1];
        colbarlbl = round(colbarticks*100)/100;

%     colbarlbl = [-1 -.1 -.01 -.001 0 .001 .01 .1 1];
else
    colbarticks = [-1:8/Ntick:-8/Ntick, 0, 8/Ntick:8/Ntick:1];
    colbarlbl = round(colbarticks*100)/100;
%     colbarlbl = [-1, -0.1, -0.01, 0 , 0.01, 0.1, 1];%*10^-caxLim;
end
fld=convert2gcmfaces(fld.*mygrid.mskC(:,:,1))*10^caxLim;
binFld = fld;
for i = 1:Ntick+1
    if i == 1
        bin = fld < ctick(i);
        binFld(bin) = ctick(i);
    elseif i == Ntick+1
        bin = fld >= ctick(i-1);
        binFld(bin) = ctick(i-1);
%     elseif i==12
%         bin = fld >= ctick(i-1) & fld < ctick(i);
%         binFld(bin) = (ctick(i-1)+ctick(i))*.5;
    else
        bin = fld >= ctick(i-1) & fld < ctick(i);
        binFld(bin) = (ctick(i-1)+ctick(i))*.5;
    end
end
binFld=convert2gcmfaces(binFld);
% fld=convert2gcmfaces(fld);
end