FROM gaow/base-notebook:1.0.0

LABEL Diana Cornejo <dmc2245@cumc.columbia.edu>

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

USER root

RUN Rscript -e 'for (pkg in c("data.table", "tidyverse", "bigsnpr", "bigsparser", "ggplot2", "gplots")) if (!(pkg %in% rownames(installed.packages()))) install.packages(pkg, repos="https://cloud.r-project.org")'
RUN Rscript -e 'install.packages("R.utils", repos="https://cloud.r-project.org")'

RUN cd /tmp && wget http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20201019.zip && \
    unzip plink_linux_x86_64_20201019.zip && \
    mv plink prettify /usr/local/bin && rm -rf /tmp/*

RUN mkdir -p /home/jovyan/.work

RUN curl -so /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh

# Add notebook startup hook
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
# This hook will configure the jupyter environment by copying the data and downloading latest version of tutorials
RUN mkdir -p /usr/local/bin/start-notebook.d
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh ldpred2" > /usr/local/bin/start-notebook.d/get-updates.sh
RUN chmod a+x /usr/local/bin/start-notebook.d/get-updates.sh
RUN chown jovyan.users -R /home/jovyan
USER jovyan

# Download data to docker image
RUN mkdir -p /home/jovyan/.work
RUN cd /home/jovyan/.work && curl -fsSL http://statgen.us/files/2021/01/ldpred2.tar.gz -o ldpred2.tar.gz && tar -xzvf ldpred2.tar.gz && rm -rf *.tar.gz
