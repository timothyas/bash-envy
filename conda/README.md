# Conda

#### Create an environment
```bash
conda env create -f environment.yaml
```

#### Add to ipykernel for Jupyter
```bash
conda activate myenv
python -m ipykernel install --user --name=myenv
```

#### Update (may or may not need the libblas line)
```bash
conda update --name myenv --channel conda-forge --all libblas=*=*mkl
```
