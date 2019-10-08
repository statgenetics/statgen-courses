FROM gaow/base-notebook:latest

MAINTAINER Gao Wang <gw2411@columbia.edu>

USER root

RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y annovar annovar-humandb statgen-king && \ 
    apt-get clean

USER jovyan

RUN conda install -c https://conda.binstar.org/bpeng variant_tools && \
    conda install scipy && \
    conda clean --all && rm -rf /tmp/* $HOME/.caches

WORKDIR $HOME

RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/notebooks/VAT.ipynb -o VAT.ipynb