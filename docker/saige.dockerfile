FROM gaow/base-notebook:1.0.0

LABEL Diana Cornejo <dmc2245@cumc.columbia.edu>

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

USER root

RUN apt-get update && \
    apt-get install -y \
    wget \
    cmake \
    libreadline-dev \
    libz-dev \
    libpcre3-dev \
    default-jre \
    libboost-all-dev \
    libpng-dev \
    libcairo2-dev \
    tabix \
    && apt-get clean

# Dependency Python packages for SAIGE pipelines
RUN pip install cget
RUN conda install -c conda-forge bgen==3.0.3 bgen-reader==3.0.7

# Dependency R packages for SAIGE
# https://github.com/weizhouUMICH/SAIGE/blob/dc642fbf4c943594cc9b05774b8bc187892eaa25/DESCRIPTION#L10
# https://github.com/weizhouUMICH/SAIGE/blob/dc642fbf4c943594cc9b05774b8bc187892eaa25/extdata/install_packages.R
RUN Rscript -e 'p = c("remotes", "Rcpp", "RcppArmadillo", "RcppParallel", "data.table", "SPAtest", "RcppEigen", "BH", "optparse", "SKAT", "MetaSKAT"); install.packages(p, repos="https://cloud.r-project.org")'
# Use a fork to remove bgen dependency because I've installed it using conda
# https://github.com/statgenetics/SAIGE/commit/465a367c1bd7169d1381975015b5dcb648e2c197
ENV SAIGE_VERSION 96125c983d952cccf9ba71c6d2fa293b59060436
RUN Rscript -e 'remotes::install_github("statgenetics/SAIGE", ref = "'${SAIGE_VERSION}'")'

USER jovyan
# Get SAIGE pipeline scripts
RUN wget https://raw.githubusercontent.com/statgenetics/SAIGE/96125c983d952cccf9ba71c6d2fa293b59060436/extdata/createSparseGRM.R
RUN wget https://raw.githubusercontent.com/statgenetics/SAIGE/96125c983d952cccf9ba71c6d2fa293b59060436/extdata/step1_fitNULLGLMM.R
RUN wget https://raw.githubusercontent.com/statgenetics/SAIGE/96125c983d952cccf9ba71c6d2fa293b59060436/extdata/step2_SPAtests.R
RUN curl -fsSL http://statgen.us/files/2020/01/saige_data.tar.gz -o saige_data.tar.gz && tar -xzvf saige_data.tar.gz && mkdir input && mv /home/jovyan/saige_data/* input/ && rm -rf *.tar.gz saige_data
RUN mkdir output
