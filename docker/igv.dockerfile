FROM dceoy/igv-webapp:latest

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

WORKDIR /root

## Install unzip
RUN apt-get update && \
apt-get install -y unzip && \
apt-get clean

## Download data for the exercise
## Data should be installed to `/usr/local/src/igv-webapp/dist` to be accessible
RUN curl -fsSL http://statgen.us/files/igv_exercise.zip -o igv_exercise.zip && unzip igv_exercise.zip && mv igv/*.* /usr/local/src/igv-webapp/dist && rm -rf igv_exercise.zip igv

## Update the exercise text
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/IGV.docx -o IGV.docx
