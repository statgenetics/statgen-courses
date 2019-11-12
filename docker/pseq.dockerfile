FROM gaow/base-notebook:1.0.0

MAINTAINER Gao Wang <gw2411@columbia.edu>

USER root
RUN curl -fsSL https://bitbucket.org/statgen/plinkseq/get/5d071291075c.zip -o plinkseq.zip && unzip plinkseq.zip && mv statgen-plinkseq* plinkseq && cd plinkseq && make && rm -f build/execs/*.o && rm -f build/execs/*.dep && mv build/execs/* /usr/local/bin && cd - && rm -rf plinkseq*
RUN curl -fsSL http://statgen.us/files/plinkseq-data.tar.bz2 -o plinkseq-data.tar.bz2 && tar jxvf plinkseq-data.tar.bz2 && rm -f plinkseq-data.tar.bz2

# Download notebook script and clean up output in the notebook
USER jovyan
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/notebooks/PSEQ.ipynb -o PSEQ.ipynb
RUN jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace PSEQ.ipynb
RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PSEQ.pdf -o PSEQ.pdf
RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PSEQ.doc -o PSEQ.doc