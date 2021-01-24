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

# Insert this to the notebook startup script,
# https://github.com/jupyter/docker-stacks/blob/fad26c25b8b2e8b029f582c0bdae4cba5db95dc6/base-notebook/Dockerfile#L151
RUN sed -i '2 i \
	pull-tutorial.sh & \
	'  /usr/local/bin/start-notebook.sh

# Content for pull-tutorial.sh script\
RUN echo '''#!/bin/bash \
	mkdir -p /tmp/.cache && \
    cd /tmp/.cache && \
    \
    wget https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/Epistasis.pdf && \
    \
	chown -R jovyan.users *.* && \
    mv *.* /home/jovyan/work \
	''' >  /usr/local/bin/pull-tutorial.sh && chmod +x /usr/local/bin/pull-tutorial.sh
RUN 

USER jovyan

# ARG DUMMY=unknown

# RUN wget https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/Epistasis.pdf
