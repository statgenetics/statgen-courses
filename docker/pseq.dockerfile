FROM gaow/base-notebook:latest

MAINTAINER Gao Wang <gw2411@columbia.edu>

USER root

# Install dependency tools
RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y plinkseq plinkseq-tutorial && \
    apt-get clean

# Download notebook script and clean up output in the notebook
USER jovyan
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/notebooks/PSEQ.ipynb -o PSEQ.ipynb
RUN jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace PSEQ.ipynb