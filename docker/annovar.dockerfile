FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

USER root
#Install dependency tools and deploy data-set package that Carl made
RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y annotation-tutorial curl && \	
    apt-get clean

#Update the exercise text
USER jovyan
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/FunctionalAnnotation.2019.docx -o FunctionalAnnotation.2019.docx 