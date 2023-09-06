FROM gaow/sos-notebook:3.1.1

LABEL Diana Cornejo <dmc2245@cumc.columbia.edu>

# PLINK and Regenie
RUN mamba install -c bioconda plink plink2 regenie=3.2.9 -y && mamba clean --all -f -y
RUN mamba install -c conda-forge r-ggrepel r-qqman -y && mamba clean --all -f -y

USER root
RUN curl -sSo /tmp/startup-hook.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/startup-hook.sh && \
   /bin/bash /tmp/startup-hook.sh regenie && rm -f /tmp/startup-hook.sh

USER jovyan

# Download data to docker image
RUN mkdir -p /home/jovyan/.work
RUN cd /home/jovyan/.work && curl -fsSL https://statgen.us/files/2021/11/mwe_regenie.tar.gz -o mwe_regenie.tar.gz && tar -xzvf mwe_regenie.tar.gz && rm -rf *.tar.gz