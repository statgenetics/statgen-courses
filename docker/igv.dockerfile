FROM dceoy/igv-webapp:latest

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

WORKDIR /root

ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/IGV.docx -o IGV.docx

## Install unzip
RUN apt-get update && \
apt-get install -y unzip && \
apt-get clean

##Download data for the exercise
USER jovyan

RUN curl -fsSL http://statgen.us/files/2017/09/data/igv_exercise.zip  -o igv_exercise.zip && unzip igv_exercise.zip &&  rm -f igv_exercise.zip &&\
 mv /home/shared/* /home/jovyan && chown jovyan.users -R /home/jovyan/*

# FIXME: add commands to download other necessary data files, if any, to current directory for distribute
