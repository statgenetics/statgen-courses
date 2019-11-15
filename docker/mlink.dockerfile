FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

USER root

# Install dependency tools fastlink from Debian package repo, currently version 4.1P
# And LINKAGE program from our own repo; overwriting packages in LINKAGE with those in FASTLINK when possible
RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y linkage fastlink && \
    apt-get clean

# Download scripts and tutorial files
USER jovyan
ARG DUMMY=unknown
RUN curl -fsSL http://statgen.us/files/peds-a.pre -o peds-a.pre