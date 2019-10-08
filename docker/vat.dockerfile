FROM gaow/base-notebook:latest

MAINTAINER Gao Wang <gw2411@columbia.edu>

USER root

RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y annovar annovar-humandb statgen-king && \ 
    apt-get clean


RUN conda install scipy pytables && \
    conda install -c https://conda.binstar.org/bpeng variant_tools && \
    conda clean --all && rm -rf /tmp/* $HOME/.caches

USER jovyan

RUN curl -fsSL http://statgen.us/files/vat.tar.bz2 -o work/vat.tar.bz2 && tar jxvf vat.tar.bz2 && rm -f vat.tar.bz2
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/notebooks/VAT.ipynb -o VAT.ipynb