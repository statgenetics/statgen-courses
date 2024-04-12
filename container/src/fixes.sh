#!/usr/bin/env bash
# r-rgl needs libGL.so.1 provided by the system package manager
apt-get -y install libgl1 libgomp1

# install plink.multivariate
curl -o /root/.pixi/bin/plink.multivariate https://github.com/statgenetics/statgen-courses/raw/master/handout/misc/plink.multivariate && chmod +x /root/.pixi/bin/plink.multivariate

# temporary fix for https://github.com/vatlab/jupyterlab-sos/issues/72
micromamba activate python_libs
pip install jupyterlab-sos --force-reinstall

# pixi global mistakenly points the samtools wrapper to samtools.pl, so we need to revert this change
#sed -i "s/samtools.pl/samtools/" /root/.pixi/bin/samtools
