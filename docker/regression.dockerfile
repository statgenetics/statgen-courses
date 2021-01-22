FROM gaow/base-notebook:1.3.0

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

# Install dependency tools and install data-set

USER root

RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
apt-get update && \
    apt-get install -y regression-tutorial && \
    apt-get clean && mv /home/shared/* /home/jovyan && rm -rf /home/shared && chown jovyan.users -R /home/jovyan/*

# Download notebook script and clean out output

USER jovyan

ARG DUMMY=unknown

RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/regression.docx -o regression.docx && \
                   curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/regression.pdf -o regression.pdf && \
                   curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/code/regression.R -o regression.R
