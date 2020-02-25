FROM dceoy/igv-webapp:latest

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

WORKDIR /root

## Install unzip
RUN apt-get update && \
    apt-get install -y unzip default-jre && \
    apt-get clean

## Download data for the exercise
## Data should be installed to `/usr/local/src/igv-webapp/dist` to be accessible

RUN curl -fsSL http://statgen.us/files/igv_exercise.zip -o igv_exercise.zip && \
    unzip igv_exercise.zip && \
    mv igv/*.* /usr/local/src/igv-webapp/dist && \
    rm -rf igv_exercise.zip igv && ln -s /usr/local/src/igv-webapp/dist igv-dist

# Also install IGV java package
RUN mkdir -p /igv && \
    cd /igv && \
    wget http://data.broadinstitute.org/igv/projects/downloads/2.4/IGV_2.4.14.zip && \
    unzip IGV_2.4.14.zip && \
    cd IGV_2.4.14 && \
    sed -i 's/Xmx4000/Xmx8000/g' igv.sh && \
    cd /usr/local/bin && \
    ln -s /igv/IGV_2.4.14/igv.sh ./igv 

## Update the exercise text
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/IGV.docx -o IGV.docx
