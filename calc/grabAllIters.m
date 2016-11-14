function [iters] = grabAllIters( searchDir, fileName )
%
% MITgcm output (e.g. from diagnostics) is listed with iteration stamps
% This script grabs all iteration numbers in 'searchDir'.
% 
% 	searchDir = directory to find output files, with iter numbers
% 	fileName = base of file name 
%
%	Ex. 
%	searchDir = '/workspace/gcmpack/results/samoc/hf-perturb/diags/'
%	fileName = 'state_2d_set1'
%
%	in directory: state_2d_set1.0000000732.(meta/data)
%		      state_2d_set1.0000001428.(meta/data)
%
%	iters = [732, 1428];
% ------------------------------------------------------------

%% Grab all the iteration numbers from the directory
if ~strcmp(searchDir(end),'/')
	searchDir = [searchDir '/'];
end
searchStr = sprintf('dir %s*.meta',[searchDir fileName]);
[status,list] = system(searchStr); 
res=textscan( list, '%s', 'delimiter', '\n' );
fileList = res{1};
Nt = length(fileList);

iters=zeros(1,Nt);

for n = 1:Nt
	% Iteration is the 42-51st digit
	iters(n) = str2num(fileList{n}(end-14:end-5));
end
end
