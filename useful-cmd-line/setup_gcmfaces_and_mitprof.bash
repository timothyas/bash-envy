#!/bin/bash

echo ''
echo ''
echo '-- Disclaimer:'
echo '-- The free software programs may be freely distributed, provided that no '
echo '-- charge is levied, and that the disclaimer below is always attached to it. '
echo '-- The programs are provided as is without any guarantees or warranty.'
echo '-- Although the authors have attempted to find and correct any bugs in the '
echo '-- free software programs, the authors are not responsible for any damage or '
echo '-- losses of any kind caused by the use or misuse of the programs.'
echo '-- The authors are under no obligation to provide support, service, '
echo '-- corrections, or upgrades to the free software programs.'
echo ''
echo ''

echo '-- Hello.'
echo ''
echo '---- the setup of gcmfaces and MITprof will start'
echo '---- by downloading the files from the MITgcm cvs server.'
echo '---- This should take a couple minutes.'
echo ''

if [ ! -f ${HOME}/.cvspass ]; then
  echo '/1 :pserver:cvsanon@mitgcm.org:2401/u/gcmpack Ah<Zy=0=' > ~/.cvspass
fi

export CVS_RSH=ssh
cvs -Q -d :pserver:cvsanon@mitgcm.org:/u/gcmpack co -P -d gcmfaces MITgcm_contrib/gael/matlab_class
cvs -Q -d :pserver:cvsanon@mitgcm.org:/u/gcmpack  co -P -d MITprof MITgcm_contrib/gael/profilesMatlabProcessing
cvs -Q -d :pserver:cvsanon@mitgcm.org:/u/gcmpack  co -P -d GRID MITgcm_contrib/gael/GRID
cvs -Q -d :pserver:cvsanon@mitgcm.org:/u/gcmpack  co -P -d OCCAetcONv4GRID MITgcm_contrib/gael/OCCAetcONv4GRID

if [ ! -d gcmfaces]; then
  echo ''
  echo '-- ERROR : code was not obtained from the cvs server.'
  echo ''
  echo '-- Most likely you already have a .cvspass file in your home dir, so '
  echo '-- we tried to use this one and this did not work. In this event'
  echo '-- you may want to try to login to the cvs as explained @ '
  echo '-- http://mitgcm.org/public/source_code.html'  
  echo '-- and execute this script again.'
  echo ''
 exit
fi

echo ''
echo '---- To test run the programs, we will download sample inputs.'
echo '---- This should take a couple minutes.'
echo ''

mkdir gcmfaces/sample_input

mv OCCAetcONv4GRID gcmfaces/sample_input/.

wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release1/nctiles_climatology/ETAN

mv mit.ecco-group.org/ecco_for_las/version_4/release1/nctiles_climatology gcmfaces/sample_input/.
rm -rf mit.ecco-group.org

echo ''
echo '---- Now a matlab session will start, and test run the programs.'
echo '---- This should take a couple minutes.'
echo ''
sleep 1

matlab -nojvm -nodisplay << EOF
  fprintf('');

  %test gcmfaces:
  cd gcmfaces;
  gcmfaces_global; 
  myenv.verbose=1;
  myenv.lessplot=1;
  myenv.lesstest=1;
  cd ..;

  gcmfaces_init;

  %test MITprof:
  is_netcdf_avail=~isempty(which('ncexample'))|~isempty(which('netcdf.create'));
  is_netcdf_redundant=~isempty(which('ncexample'))&~isempty(which('netcdf.create'));
  if (is_netcdf_redundant);
    fprintf('\n\n!! You have both the old mex/netcdf and the native matlab/netcdf installed.\n');
    fprintf('!! Since they are conflicting (name clashes) you will likely run into trouble. \n');
    fprintf('!! You may want to remove the old mex/netcdf stuff from your matlab path.\n\n');
  end;
  if ~is_netcdf_avail; 
    fprintf('\n !!!! Error: Using MITprof cannot be \n used until you get the netcdf toolbox.\n'); 
  else;
    cd MITprof;
    profiles_process_init;
    cd ..;
  end;

  exit
EOF
echo ''

echo ''
echo '---- Assuming the test runs have succesfully completed, you should be all set.'
echo ''
echo '---- To be able to use the packages in future matlab sessions, you will'
echo '---- need to add directories to your matlab path -- those are listed'
echo '---- in gcmfaces/gcmfaces_path.m and MITprof/MITprof_path.m -- executing'
echo '---- those two scripts is one way of completing your path.'
echo ''
echo '-- Bye.' 
