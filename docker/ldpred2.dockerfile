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

RUN curl -so /opt/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /opt/pull-tutorial.sh
# Users will be asked to type in "get-data" command in bash when they run the tutorial the first time.
RUN echo "#!/bin/bash\n/opt/pull-tutorial.sh ldpred2" > /usr/local/bin/get-data
RUN chmod a+x /usr/local/bin/get-data

USER jovyan

# Download data to docker image
RUN mkdir -p /home/jovyan/.work
RUN cd /home/jovyan/.work && curl -fsSL http://statgen.us/files/2021/01/ldpred2.tar.gz -o ldpred2.tar.gz && tar -xzvf ldpred2.tar.gz && rm -rf *.tar.gz
