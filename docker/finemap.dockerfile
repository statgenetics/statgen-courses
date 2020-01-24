FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo  <dmc2245@cumc.columbia.edu>
   
#Install susieR
#Install associated R packages
#Download data under the jovyan directory

USER root

RUN R -e 'remotes::install_github("stephenslab/susieR@0.9.0")' && \
    R -e 'install.packages("glmnet", repos="http://cran.r-project.org")' && \
    R -e 'install.packages("abind", repos="http://cran.r-project.org")'
    
USER jovyan

ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL http://statgen.us/files/2020/01/finemapdata.tar.gz  -o data.tar.gz && \
    tar -zxvf data.tar.gz && \
    mv finemapdata/* ./  && \
    rm -rf finemapdata* data.tar.*
RUN jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace finemap_ex.ipynb
