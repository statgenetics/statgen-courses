#!/usr/bin/env bash
# r-rgl needs libGL.so.1 provided by the system package manager
apt-get -y install libgl1 libgomp1

# install cASSI
curl -o /root/cassi-v2.51-linux-x86_64.zip https://www.staff.ncl.ac.uk/richard.howey/cassi/cassi-v2.51-linux-x86_64.zip && unzip -d /root /root/cassi-v2.51-linux-x86_64.zip && cp /root/cassi-v2.51-linux-x86_64/cassi /usr/local/bin/ && chmod +x /usr/local/bin/cassi

# clean up
rm /root/cassi-v2.51-linux-x86_64.zip

# pixi global mistakenly points the samtools wrapper to samtools.pl, so we need to revert this change
#sed -i "s/samtools.pl/samtools/" /root/.pixi/bin/samtools

# install perl modules
apt-get install --yes perl-modules