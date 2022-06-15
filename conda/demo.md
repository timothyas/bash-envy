# A quick conda demo

## Manual installation

Create an environment with python 3.10

```bash
conda create --name demo python=3.10
```

Install some packages into the environment

```bash
conda install --name demo1 --channel conda-forge numpy scipy matplotlib xarray
```

Lets step inside the environment

```bash
conda activate demo1
```

Now if we install packages, they are automatically installed to the active
environment

```bash
conda install --channel conda-forge netCDF4
```

How about cartopy...

```bash
conda install -c conda-forge cartopy
conda deactivate
```

## Make an environment with a yaml file

```bash
conda env create -f demo.yaml
conda activate demo
python -m ipykernel install --user --name=demo
conda deactivate
```

Now the environment should be visible from Jupyter lab
