FROM gaow/base-notebook:latest

MAINTAINER Gao Wang <gw2411@columbia.edu>

WORKDIR /tmp

USER root

RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y annovar annovar-humandb statgen-king && \ 
    apt-get clean

USER jovyan

RUN conda install -c bpeng variant_tools && \
    conda build purge-all && rm -rf /tmp/* $HOME/.caches