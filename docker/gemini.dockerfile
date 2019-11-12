FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

USER root
#Install dependency tools and deploy data-set package that Carl made
RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y gemini && \
    apt-get clean && chown jovyan.users -R /home/jovyan/*

#Update the exercise text
USER jovyan
ARG DUMMY=unknown
 
