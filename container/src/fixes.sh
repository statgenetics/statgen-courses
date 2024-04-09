#!/usr/bin/env bash

# r-rgl needs libGL.so.1 provided by the system package manager
apt-get -y install libgl1 libgomp1

# Only show PYTHONPATH and R_LIBS to specific executables
sed -i '2i export PYTHONPATH="/root/micromamba/envs/python_libs/lib/python3.12/site-packages"' /root/.pixi/bin/python
sed -i '2i export PYTHONPATH="/root/micromamba/envs/python_libs/lib/python3.12/site-packages"' /root/.pixi/bin/python3
sed -i '2i export PYTHONPATH="/root/micromamba/envs/python_libs/lib/python3.12/site-packages"' /root/.pixi/bin/jupyter-lab
sed -i '2i export PYTHONPATH="/root/micromamba/envs/python_libs/lib/python3.12/site-packages"' /root/.pixi/bin/jupyter-server

sed -i '2i export R_LIBS="/root/micromamba/envs/r_libs/lib/R/library"' /root/.pixi/bin/r
sed -i '2i export R_LIBS="/root/micromamba/envs/r_libs/lib/R/library"' /root/.pixi/bin/rscript
sed -i '2i export R_LIBS="/root/micromamba/envs/r_libs/lib/R/library"' /root/.pixi/bin/jupyter-lab
sed -i '2i export R_LIBS="/root/micromamba/envs/r_libs/lib/R/library"' /root/.pixi/bin/jupyter-server
echo "unset PYTHONPATH" >> /root/.bashrc

# pixi global currently gives it wrappers all lowercase names, so we need to make symlinks for R and Rscript
ln -sf /root/.pixi/bin/r /root/.pixi/bin/R
ln -sf /root/.pixi/bin/rscript /root/.pixi/bin/Rscript

# pixi global mistakenly points the samtools wrapper to samtools.pl, so we need to revert this change
#sed -i "s/samtools.pl/samtools/" /root/.pixi/bin/samtools
