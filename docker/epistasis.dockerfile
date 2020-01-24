FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo  <dmc2245@cumc.columbia.edu>

#Install dependecy tools and download datasets

USER root
     
RUN apt-get update && \
    apt-get install g++ && \		
    conda install -c bioconda plink && \
    apt-get clean

RUN curl -fsSL https://www.staff.ncl.ac.uk/richard.howey/cassi/cassi-v2.51-code.zip -o cassi.zip && \
    unzip cassi.zip && cd cassi-v2.51-code && g++ -m64 -O3 *.cpp -o cassi && mv cassi /usr/local/bin && cd - && rm -rf cass*

RUN curl -fsSL http://statgen.us/files/2020/01/PRACDATA.zip -o PRACDATA.zip && unzip PRACDATA.zip && mv PRACDATA/simcasecon.*  /home/jovyan  && rm -rf PRACDAT* && \ 
    chown jovyan.users -R /home/jovyan/*

USER jovyan

ARG DUMMY=unknown

RUN wget https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/Epistasis-NY2020.pdf
