FROM gaow/base-notebook:latest

MAINTAINER Gao Wang <gw2411@columbia.edu>

WORKDIR /tmp

USER root

RUN echo "deb [trusted=yes] https://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y vtools-tutorial annovar annovar-humandb statgen-king && \ 
    apt-get clean

USER jovyan

RUN conda install -c https://conda.binstar.org/bpeng variant_tool && \
    conda clean --all -tipsy && rm -rf /tmp/* $HOME/.caches
