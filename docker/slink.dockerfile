FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

# Install dependency tools and deploy data-set package that Carl made

USER root

RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y fastslink && \
    apt-get clean

# Download scripts and tutorial files

USER jovyan

RUN curl -fsSL http://statgen.us/files/slink-data.tar.bz2 -o slink-data.tar.bz2 && tar jxvf slink-data.tar.bz2 && rm -f slink-data.tar.bz2

RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/Slink.doc -o slink.doc

