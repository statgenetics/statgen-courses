FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

# Install dependency tools and deploy data-set package that Carl made

USER root

RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 
# Problem using letsencrypt for staten.us and a solution
# https://stackoverflow.com/questions/69401972/refresh-lets-encrypt-root-ca-in-docker-container
RUN sed -i 's/mozilla\/DST_Root_CA_X3.crt/!mozilla\/DST_Root_CA_X3.crt/g' /etc/ca-certificates.conf
RUN update-ca-certificates
RUN echo "deb [trusted=yes] https://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y fastslink && \
    apt-get clean

# Download scripts and tutorial files

USER jovyan

RUN curl -fsSL https://statgen.us/files/slink-data.tar.bz2 -o slink-data.tar.bz2 && tar jxvf slink-data.tar.bz2 && rm -f slink-data.tar.bz2

RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/Slink.doc -o slink.doc

