
if ~exist('mygrid','var')
  runDir='/workspace/gcmpack/GRID/';
  grid_load(runDir,5, 'compact');
  gcmfaces_global;
end
