#!/usr/bin/env bash
# r-rgl needs libGL.so.1 provided by the system package manager
apt-get -y install libgl1 libgomp1

# pixi global mistakenly points the samtools wrapper to samtools.pl, so we need to revert this change
#sed -i "s/samtools.pl/samtools/" /root/.pixi/bin/samtools

# install perl modules
apt-get install --yes perl-modules
