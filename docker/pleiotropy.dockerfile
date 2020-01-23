FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo  <dmc2245@cumc.columbia.edu>

#Install plink==1.9 and R libraries
#Download Andrew's datasets from statgen.us 

USER root
     
RUN conda install -c bioconda plink && \
    R -e 'install.packages("mediation", repos="http://cran.r-project.org")'

RUN curl -fsSL http://statgen.us/files/2020/01/pleiotropy_final_datasets.zip -o pleiotropy.zip && unzip pleiotropy.zip && mv pleiotropy_final_datasets/*  /home/jovyan  && \
    rm -rf pleiotro* && \ 
    chown jovyan.users -R /home/jovyan/*

RUN cd /usr/local/bin && curl -fsSL https://genepi.qimr.edu.au/staff/manuelF/multivariate/plink.multivariate -o plink.multivariate && chmod a+x plink.multivariate 

USER jovyan

ARG DUMMY=unknown

RUN curl -fsSL https://github.com/statgenetics/statgen-courses/blob/master/handout/Pleiotropy.docx -o Pleiotropy.docx
RUN curl -fsSL https://github.com/statgenetics/statgen-courses/blob/master/handout/Pleiotropy_answers.docx -o Pleiotropy_answers.docx
RUN curl -fsSL https://github.com/statgenetics/statgen-courses/blob/master/handout/pleiotropy_commands.txt  -o pleiotropy_commands.txt
