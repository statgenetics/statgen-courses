FROM gaow/base-notebook:1.0.0

LABEL Diana Cornejo <dmc2245@cumc.columbia.edu>

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

USER root

# Download and install PLINK2 version alpha2.3 date:01-24-2020

RUN cd /tmp && wget http://s3.amazonaws.com/plink2-assets/alpha2/plink2_linux_x86_64.zip  && \
    unzip plink2_linux_x86_64.zip && \
    cp plink2 /usr/local/bin && \
    rm -rf plink2*

#Download and install  PLINK1.9 beta6.21 date:10-19-2020
RUN cd /tmp && wget http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20201019.zip && \
    unzip plink_linux_x86_64_20201019.zip && \
    cp plink /usr/local/bin && \
    rm -rf plink

#Download and install R packages
RUN Rscript -e 'p = c("data.table", "ggplot2", "ggrepel", "dplyr", "qqman"); install.packages(p, repos="https://cloud.r-project.org")'

#Download and install regenie
RUN cd /tmp && wget https://github.com/rgcgithub/regenie/releases/download/v2.2.4/regenie_v2.2.4.gz_x86_64_Linux.zip && \
    unzip regenie_v2.2.4.gz_x86_64_Linux.zip && chmod a+x regenie_v2.2.4.gz_x86_64_Linux && mv regenie_v2.2.4.gz_x86_64_Linux regenie && \
    cp regenie /usr/local/bin && \
    rm regenie_v2.2.4.gz_x86_64_Linux.* 

RUN curl -sSo /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh
# Add notebook startup hook
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
RUN mkdir -p /usr/local/bin/start-notebook.d
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh README" > /usr/local/bin/start-notebook.d/get-updates.sh
RUN chmod a+x /usr/local/bin/start-notebook.d/get-updates.sh
# Users can type in "get-data" command in bash when they run the tutorial the first time, to download the data.
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh regenie" > /usr/local/bin/get-data
RUN chmod a+x /usr/local/bin/get-data

RUN chown jovyan.users -R /home/jovyan

USER jovyan

# Download data to docker image
RUN mkdir -p /home/jovyan/.work
RUN cd /home/jovyan/.work && curl -fsSL https://statgen.us/files/2021/11/mwe_regenie.tar.gz -o mwe_regenie.tar.gz && tar -xzvf mwe_regenie.tar.gz && rm -rf *.tar.gz
