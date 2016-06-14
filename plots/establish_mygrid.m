
if ~exist('mygrid','var')
  if ismac
	runDir = '~/Documents/gcmpack/GRID/'
  else
  	runDir='/workspace/gcmpack/GRID/';
  end
  grid_load(runDir,5, 'compact');
  gcmfaces_global;
  gcmfaces_lines_zonal;
end
