FROM ubuntu:latest

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

WORKDIR /root

#Install dependency tools and deploy data-set package that Carl made
RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y annotation-tutorial curl && \	
    apt-get clean

#Update the exercise text
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/FunctionalAnnotation.2019.docx 

