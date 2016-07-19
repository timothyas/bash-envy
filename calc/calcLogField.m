function[ladxx] = calcLogField(adxx, mygrid)
%% Get log of adjoint field for nice plotting
% Inputs: 
%       adxx : gcmfaces object containing (e.g.) sensitivity field
% (opt) mygrid : ...
%
% Output:
%       ladxx : log10 of adxx, where sign(ladxx) = sign(adxx)
% -------------------------------------------------------------------------

if isa(adxx,'gcmfaces'), convert2gcmfaces(adxx); end
if nargin < 2, establish_mygrid; end

%% adxx is not gcmfaces type for this bit
sn = sign(adxx);
ladxx = log10(abs(adxx));
ladxx(adxx==0) = 0; 

%% Convert back
sn=convert2gcmfaces(sn);
ladxx=convert2gcmfaces(ladxx);
% adxx=convert2gcmfaces(adxx); 

%% Return log10 of adxx with sign
ladxx=ladxx.*sn;

end