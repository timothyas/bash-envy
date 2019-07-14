#!/bin/bash

# Setup an anaconda test environment with the necessary packages


conda create -n test_env anaconda

conda install -n test_env xarray netcdf4 bottleneck future

conda install -n test_env -c conda-forge cartopy docrep pyresample cmocean

conda activate test_env
