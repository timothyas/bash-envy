# Attempt at getting a MATLAB kernel for Jupyter Notebooks on Sverdrup

1. Create a anaconda environment environment with python version
    2.7, 3.4, 3.5, or 3.6 and 
   in the environment, install matlab_kernel: https://github.com/calysto/matlab_kernel
    e.g. by adding

    ```
    - pip
    - pip:
        - matlab_kernel
    ```

    to a yml file 

2. I activated the environment and installed it to jupyter notebook, but
    this may not be necessary

3. Install matlab for python, on sverdrup this required doing so in nondefault
    locations. Instructions here: 

    https://www.mathworks.com/help/matlab/matlab_external/install-matlab-engine-api-for-python-in-nondefault-locations.html 

    I put the build directory in /scratch/shared/matlab_py36_build
    and pointed the install directory to /scratch/shared/anaconda3/

4. Open an interactive session and run

    ```
    module load matlab
    conda activate matlab_env # <- use whatever your anaconda env name is
    export PYTHONPATH=$PYTHONPATH:/scratch/shared/matlab_py36_build
    ```

5. Connect to notebook, and create a notebook with a Matlab kernel
    However I kept getting this error: 

    ```
    ImportError: /opt/apps/matlab/r2017b/extern/engines/python/dist/matlab/engine/glnxa64/../../../../../../../sys/os/glnxa64/libstdc++.so.6: version `CXXABI_1.3.9' not found (required 
by /scratch/shared/anaconda3/envs/matlab_py36/lib/python3.6/site-packages/zmq/backend/cython/../../../../../libzmq.so.5)
    ```

    I tried pointing LD_LIBRARY_PATH to a different directory, namely by

    ```
    export LD_LIBRARY_PATH=/scratch/shared/anaconda3/envs/matlab_py36/lib
    ```

    but to no avail.
    
