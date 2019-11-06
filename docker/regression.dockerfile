FROM gaow/base-notebook:latest

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

USER root

#Install dependency tools and install data-set

RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
apt-get update && \
    apt-get install -y regression-tutorial && \
    apt-get clean && mv /home/shared/* /home/jovyan && chown jovyan.users -R /home/jovyan/*

#Download notebook script and clean out output

USER jovyan
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/regression.docx -o regression.docx
RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/regression.pdf -o regression.pdf
RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/code/regression.R -o regression.q

