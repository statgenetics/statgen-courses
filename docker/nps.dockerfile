FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo  <dmc2245@cumc.columbia.edu>

USER root

RUN apt-get update && \
    apt-get install curl make gcc g++ libopenblas-dev --yes && \
    apt-get clean && \
    curl -O https://cloud.r-project.org/src/base/R-3/R-3.5.1.tar.gz && \
    tar xvzf R-3.5.1.tar.gz && \
    cd R-3.5.1 && \
    ./configure --with-x=no --with-blas="-lopenblas" && \
    make && \
    mkdir -p /usr/local/lib/R/lib && \
    make install && \
    cd .. && \
    rm -rf R-3.5.1*
   
#Install and compile NPS1.1
#Install associated R packages

RUN curl -fsSL https://github.com/sgchun/nps/archive/1.1.tar.gz -o nps-1.1.tar.gz && \
    tar xvzf nps-1.1.tar.gz && \
    cd nps-1.1/ && \
    make && \
    rm -rf nps-1.1.tar.gz

RUN cd nps-1.1/ && \
    Rscript -e 'install.packages("pROC", repos="http://cran.r-project.org")' && \
    Rscript -e 'install.packages("DescTools", repos="http    ://cran.r-project.org")' && \
    mv nps-1.1/ /home/jovyan


#Download NPS test data and place it under testdata/ folder

USER jovyan
RUN cd nps-1.1/testdata/
RUN curl -fsSL http://statgen.us/files/NPS.Test1.tar.gz -o NPS.Test1.tar.gz && \
    tar xvzf NPS.Test1.tar.gz && \
    rm -rf NPS.Test1.tar.gz &&\
    cd ..

