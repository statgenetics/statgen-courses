FROM gaow/base-notebook

MAINTAINER Guangyou Li <llxxhz55555@gmail.com>

USER root

# PLINK
RUN wget http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20200616.zip && \
    unzip plink_linux_x86_64_20200616.zip && mv plink /usr/local/bin &&  chmod +x /usr/local/bin/plink && rm -rf /tmp/*

# python 2
RUN mkdir -p /opt/miniconda2 \
    && wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -bfp /opt/miniconda2 \
    && rm -rf /tmp/miniconda.sh 

RUN /opt/miniconda2/bin/pip install pyGWAS pandas scipy

# MetaXcan
#RUN pip install metaX

# R
RUN R --slave -e "for (p in c('abind','data.table','tibble','modelr','purrr','RSQLite')) if (!(p %in% rownames(installed.packages()))) install.packages(p, repos = 'http://cran.rstudio.com')"
RUN R --slave -e "install.packages(c('optparse','RColorBrewer', 'RcppEigen','glmnet','HDCI'))"

# MR-JTI
RUN wget -O /tmp/MR-JTI.zip "https://www.dropbox.com/sh/i9elg3m4wav4o5g/AAABdxZbVyBclbfa_1KKVftDa?dl=0" && \
    unzip /tmp/MR-JTI.zip -x / -d /tmp/MR-JTI/ && \
    mkdir -p /opt/MR_JTI && \
    mv /tmp/MR-JTI/src/* /opt/MR_JTI && \
    chown root.root -R /opt/MR_JTI && \
    find /opt/MR_JTI -type d -exec chmod 775 {} \; && \
    find /opt/MR_JTI -type f -exec chmod 664 {} \; && \
    echo -e '#!/bin/bash\n/opt/miniconda2/bin/python /opt/MR_JTI/MetaXcan/software/MetaXcan.py $@' > /usr/local/bin/MetaXcan.py && \
    chmod +x /usr/local/bin/MetaXcan.py && \
    mkdir -p /home/jovyan/.work/ && \
    mv /tmp/MR-JTI/data /home/jovyan/.work/ && \
    rm -rf /tmp/*

# JupyterLab setup 
RUN curl -sSo /opt/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /opt/pull-tutorial.sh
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
RUN mkdir -p /usr/local/bin/start-notebook.d
RUN echo -e '#!/bin/bash\n/usr/local/bin/pull-tutorial.sh twas &' > /usr/local/bin/start-notebook.d/get-updates.sh
RUN chmod a+x /usr/local/bin/start-notebook.d/get-updates.sh
# Users can type in "get-data" command in bash when they run the tutorial the first time.
RUN echo -e '#!/bin/bash\n/opt/pull-tutorial.sh twas' > /usr/local/bin/get-data
RUN chmod a+x /usr/local/bin/get-data

RUN chown jovyan.users -R /home/jovyan

USER jovyan
