FROM gaow/sos-notebook

LABEL Diana Cornejo <dmc2245@cumc.columbia.edu>

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

USER root

# PLINK and Regenie
RUN mamba install -c bioconda plink plink2 regenie=3.2.9 -y
Run mamba install -c conda-forge r-ggrepel r-qqman -y

RUN curl -sSo /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh
# Add notebook startup hook
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
RUN mkdir -p /usr/local/bin/start-notebook.d
# For large files, you can put README as a placeholder instead of `regenie` to skip pre-loading any files to it
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh regenie" > /usr/local/bin/start-notebook.d/get-updates.sh
RUN chmod a+x /usr/local/bin/start-notebook.d/get-updates.sh
# Users can type in "get-data" command in bash when they run the tutorial the first time, to download the data.
RUN cp /usr/local/bin/start-notebook.d/get-updates.sh /usr/local/bin/get-data

RUN chown jovyan.users -R /home/jovyan

USER jovyan

# Download data to docker image
RUN mkdir -p /home/jovyan/.work
RUN cd /home/jovyan/.work && curl -fsSL https://statgen.us/files/2021/11/mwe_regenie.tar.gz -o mwe_regenie.tar.gz && tar -xzvf mwe_regenie.tar.gz && rm -rf *.tar.gz