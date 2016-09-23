if ismac
  addpath(genpath('~/Documents/MATLAB/matlab-repo/GSW'));
  addpath(genpath('~/Documents/gcmpack/gcmfaces'));
  addpath(genpath('~/Documents/gcmpack/MITprof'));
  addpath(genpath('~/Documents/gcmpack/MITgcm/utils/matlab/'))
  addpath(genpath('~/Documents/gcmpack/MITgcm/utils/mexcdf/'))
  addpath(genpath('~/Documents/MATLAB/matlab-repo/m_map'));
  addpath(genpath('~/Documents/gcmpack/gcm-contrib/plots/'));
  addpath(genpath('~/Documents/gcmpack/gcm-contrib/calc/'));
  addpath(genpath('~/Documents/MATLAB/matlab-repo/redblue'));
else
  addpath(genpath('/workspace/gcmpack/gcmfaces'));
  addpath(genpath('/workspace/gcmpack/MITprof'));
  addpath(genpath('/workspace/gcmpack/MITgcm/utils/matlab/'))
  addpath(genpath('/h2/tsmith/Documents/MATLAB/matlab-repo/m_map'))
  addpath(genpath('/h2/tsmith/Documents/MATLAB/matlab-repo/GSW'))
  addpath(genpath('/workspace/gcmpack/gcm-contrib/plots/'))
  addpath(genpath('/workspace/gcmpack/gcm-contrib/calc/'));
  addpath(genpath('/h2/tsmith/Documents/MATLAB/matlab-repo/redblue'));
end
set(0,'DefaultFigurePosition', [25 550 750 600]);
set(0, 'DefaultAxesFontSize', 16);
set(0, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultLineLineWidth', 2);
set(0, 'DefaultAxesLineWidth', 2);
set(0, 'DefaultPatchLineWidth', 2);
% set(0, 'DefaultAxesFontWeight','bold');
set(0, 'DefaultFigureColor',[1 1 1]);

