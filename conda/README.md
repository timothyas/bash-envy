# Anaconda & Miniconda Installation Notes

A half tutorial, half "note-to-self" for how I installed
workable anaconda environments on my mac, linux desktop (Ekman), and 
the CRIOS cluster Sverdrup.

## Download and install

Download the appropriate binary from [here](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html)
and follow instructions on command line install. 

## Terminology

Some of the terms in this are "channels", "environments", and "packages".
To read more about what these are, see [this page in the anaconda documentation](https://docs.conda.io/projects/conda/en/latest/user-guide/concepts/index.html)


## Setting up environments

First it's a good idea to create an environment before installing 
all of these packages. 

To me, it makes sense to create conda environments
based on a particular python version, since everything seems to be (mostly)
based on that. 
Other choices might be: if you want create an environment which installs
numpy with the intel MKL libraries rather than OpenBLAS, or vice versa
(this boils down to the specified "channel" packages are installed from, more later).
Another choice might be if you get into using holoviews/geoviews rather 
than matplotlib, it might be nice to keep an environment with holoviews/geoviews 
updates separate, although it is probably not critical...

### Methods for creating environments

You can either create an environment and add each package separately
or you can simply specify a YAML formatted specification file. 

See [here](https://docs.conda.io/projects/conda/en/latest/user-guide/getting-started.html#managing-environments)
for more on creating environments.

## "Manual" environment creation

Here I create an environment based on python version 3.7.

```
conda env create -n myenv python=3.7 anaconda
```

Note you should swap out `myenv` with whatever you want to name
this environment.
Typically, I name based on python versions, e.g. py37. 

and then "activate" this package as follows:

```
conda activate myenv
```

and note that any time that you want to use the packages we are soon to add,
you will need to activate the environment (e.g. before launching a jupyter notebook).

Note: I absolutely recommend using python versions greater than 3, and really >3.5 
is a good idea.
Many packages no longer support versions <3, and 3 has a lot of convenient features.

### Add the conda-forge channel

In short, anaconda has a default channel where it provides many packages.
However, a lot of the packages we need are on the conda-forge channel, which
is basically a "one-stop-shop" for a lot of open source projects largely
hosted on github.
For more information on this, see [here](https://conda-forge.org/docs/user/introduction.html).

```
conda config --add channels conda-forge
```

If using conda version <4.6 you will need to set priority to strict

```
conda config --set channel_priority strict
```

to prioritize packages from the conda forge channel.

Note: it's a good idea to install only from `conda-forge` channel, or from the
default channel when possible, rather than a mix.
I have previously operated with a mix, but it is much
easier to run into confusing, low-level dependency issues while doing this.

One of the few reasons I can see to use the default channel is that
numpy on the default channel is installed with Intel MKL packaged 
BLAS routines, while conda-forge is installed with OpenBLAS.
However, the conda-forge is relatively recently compatible with MKL, and
this backend can be specified. 
See notes at the bottom for more.



### Critical packages

See [here](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#creating-an-environment-with-commands)
for more on adding these packages "manually" in the command line.

The following packages are necessary for relatively standard MITgcm/ECCO
type analysis, and are necessary for the following packages:

- [ECCOv4-py](https://github.com/ECCO-GROUP/ECCOv4-py)
- [xmitgcm](https://xmitgcm.readthedocs.io/en/latest/)
- [xgcm](https://xgcm.readthedocs.io/en/latest/) 
- [MITgcmutils](https://mitgcm.readthedocs.io/en/latest/utilities/utilities.html#mitgcmutils)

### Non-developer version

If you want to install the MITgcm related packages so that you can modify
them as a developer, then you will need to clone the repo from GitHub
(see below).

Otherwise, these can easily be installed as well: 

```
conda install future xarray netCDF4 cartopy docrep pyresample cftime
conda install xmitgcm xgcm
```

ECCOv4-py is not (yet) on conda-forge, so we need to install it via pip.

```
pip install ecco_v4_py
```

Note that it is typically not a good idea to use a mix of pip and conda.
But it seems to be ok in this case...

Finally, MITgcmutils, which has commands familiar to the matlab 
user like `rdmds` and `wrmds`, can be accessed by pointing python
to a directory with an MITgcm checkout.
This is done by e.g. adding the following to your `.bash_profile` (or
`.bashrc`) file:

```
export PYTHONPATH=$PYTHONPATH:/path/to/MITgcm/utils/python/MITgcmutils
```

Or it can be installed via pip

```
pip install MITgcmutils
```


### Developer version

For a "developer" version of this environment, where these MITgcm packages
are cloned from GitHub, then go here. 
Please follow, for example, a developer workflow specified 
[here from xmitgcm](https://xmitgcm.readthedocs.io/en/latest/development.html#develpment-workflow) (which includes a link discussing how to fork a repo).

First, go to the respective repo and fork it.
Then clone the repo and point python to where you cloned it by adding
the following to your `.bash_profile` (or `.bashrc`) file:

```
export PYTHONPATH=$PYTHONPATH:/path/to/xmitgcm
export PYTHONPATH=$PYTHONPATH:/path/to/xgcm
export PYTHONPATH=$PYTHONPATH:/path/to/ECCOv4-py
```

You'll need these packages as above:

```
conda install future xarray netCDF4 cartopy docrep pyresample cftime
```

Additionally, you'll need the following dependent packages:

```
conda install cachetools pytest-cov codecov black
```

I'm not sure if these are necessary for helping develop these packages,
but are not a bad idea:

```
conda install fsspec zarr 
```

### Additional, cool packages

The following are not necessary
but are cool packages

```
conda install zarr datashader
conda install -c conda-forge cmocean xesmf
conda install -c conda-forge holoviews geoviews
```

Note that holoviews and geoviews are "recommended" to be installed via
the pyviz channel, but with all the other packages from conda-forge, they
should also be installed from conda-forge in order to avoid problems.

Another package is [MITgcm_recipes](https://github.com/raphaeldussin/MITgcm-recipes), 
created by [Raphael Dussin](https://github.com/raphaeldussin).
It is useful for ASTE users, but note that Raphael (I think) is no longer working
ASTE or MITgcm, so it's not "in development".
Note also the functionality could and should be wrapped into the ECCOv4-py package,
and [there is some discussion about this](https://github.com/ECCO-GROUP/ECCOv4-py/issues/38),
and we are happily accepting volunteers.

### Miniconda: TBD

I haven't tried this with miniconda, 
which is like anaconda but with no packages added by default.
If using miniconda, you will (at least) need to add:

```
conda install dask bottleneck
```

you will likely need more though.

## Creating an environment With a specification file

See [py37-all.yml](https://github.com/timothyas/bash-envy/blob/master/conda/py37-all.yml) in this directory for a specification file and run


```
conda env create -f py37-all.yml
```

or see [py37-dev.yml](https://github.com/timothyas/bash-envy/blob/master/conda/py37-dev.yml)
for the "developers version".

```
conda env create -f py37-dev.yml
```

for whether you prefer to install the MITgcm related packages from
conda/pip or from GitHub.

## Notes

### Install numpy from conda forge with MKL BLAS

See [this issue](https://github.com/conda-forge/numpy-feedstock/issues/153)
and create such an environment with

```
conda create -y -n test -c conda-forge numpy libblas=*=*mkl
```

But note that `update --all` will be tricky...

 
### Debug corrupted packages


If you have trouble with corrupted packages, like mkl, with messages like
 
```
CondaVerificationError: The package for mkl located at /workspace/anaconda3/pkgs/mkl-2019.3-199
appears to be corrupted. The path 'lib/libmkl_avx512.so'
specified in the package manifest cannot be found.
```

then run the following command

```
conda clean --packages --tarballs
```

