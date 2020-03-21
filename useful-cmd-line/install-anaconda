#### How I installed anaconda on
#
#   - my mac
#   - Ekman
#   - Sverdrup
#
#### 
#
# --- 1. Download appropriate file for Mac or linux here 
#   https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html
#
# --- 2. Follow prompt ... on sverdrup, I installed to /home/tsmith/anaconda3
#
# --- 3. Creating environments: 
#
# First: the manual way!
#
# First it's a good idea to create an environment before installing 
# all of these packages. To me, it makes sense to create conda environments
# based on a particular python version, since everything seems to be (mostly)
# based on that. Other things matter, like the conda version, etc. but
# I've found that it is easier to update these aspects, while changing the
# underlying python version is more tricky.

# Here I create an environment based on python version 3.7

    conda env create -n py37 python=3.7 anaconda

# (See https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#creating-an-environment-with-commands)


# Now activate the environment:

    conda activate py37

# Now add all the packages we want:

    conda install future xarray netCDF4 cartopy

# bottleneck, dask are now standard in anaconda
# Note: based on my last installation, it seems worth trying to install
# cartopy from pkgs/main raither than conda-forge...
# because installing from conda-forge makes the 
# pkgs/main::conda -> conda-forge::conda
# therefore first try:
    conda install cartopy
    conda install -c conda-forge docrep pyresample
# if this doesn't work then add cartopy to the list above, before docrep

# The following are not necessary
# but are cool packages

    conda install zarr datashader
    conda install -c conda-forge cmocean xesmf
    conda install -c pyviz holoviews geoviews


# Note: the -c conda-forge says "get this package from the conda-forge channel"
# where the conda-forge channel is where a lot of open source projects exist
#
#

# --- 3.2 Do this all in one step

# We can specify the python version and all of the packages we want with a .yml
# spec file

    conda env create py37 -f environment-py37.yml

# whatever your

 
# --- 3.5 NOTE:
#
#
# if you have trouble with corrupted packages, like mkl, with messages like
# 
# CondaVerificationError: The package for mkl located at /workspace/anaconda3/pkgs/mkl-2019.3-199
# appears to be corrupted. The path 'lib/libmkl_avx512.so'
# specified in the package manifest cannot be found.
# 
# then run the following command
#
    conda clean --packages --tarballs
    

# --- 4. I cloned the following repos so I could modify them
# but these can also be installed "the easy way"

#    ECCOv4-py
#        Easy way: pip install ecco_v4_py
#            Note: unfortunately, this package is not yet on conda ... 
#                we need to address this!
#        My way:
#            1. git clone git@github.com/ECCO-GROUP/ECCOv4-py.git
#            2. add to bashrc:
#                export PYTHONPATH=$PYTHONPATH:/path/to/ECCOv4-py
#
#    xgcm
#        -- needs xarray, which uses netCDF4 and bottleneck (latter for speed)
#        -- needs docrep and future
#        Easy way: see https://xgcm.readthedocs.io/en/latest/installation.html
#        My way:
#            1. git clone git@github.com:xgcm/xgcm.git
#            2. add to bashrc: 
#                export PYTHONPATH=$PYTHONPATH:path/to/xgcm
#            
#    xmitgcm
#        -- needs xgcm   
#        Easy way: see https://xmitgcm.readthedocs.io/en/latest/installation.html
#        My way:
#            1. git clone git@github.com:xgcm/xmitgcm.git
#            2. add to bashrc: 
#                export PYTHONPATH=$PYTHONPATH:path/to/xmitgcm
#
#    MITgcm_recipes
#        Might be useful, not critical. Raphael is no longer working
#        with ASTE or MITgcm it seems
#        Some ASTE plotting scripts from Raphael Dussin
#            1. git clone git@github.com:raphaeldussin/MITgcm-recipes.git
#            2. add to bashrc: 
#                export PYTHONPATH=$PYTHONPATH:path/to/MITgcm-recipes
#
#    MITgcmutils
#        this has the necessary rdmds or wrmds functions for reading to numpy arrays
#        (1) one can point to it's location in the directory MITgcm/utils/python via
#
#          add to bashrc:
#           export PYTHONPATH=$PYTHONPATH:/path/to/MITgcm/utils
#        (2) can be installed with pip
#            pip install MITgcmutils
