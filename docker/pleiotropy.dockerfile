FROM gaow/base-notebook:1.0.0

LABEL maintainer="Diana Cornejo <dmc2245@cumc.columbia.edu>"

#Install plink==1.9 and R libraries
#Download Andrew's datasets from statgen.us 

USER root
     
RUN mkdir /home/jovyan/.work

RUN conda install -c bioconda plink && \
    R -e 'install.packages("mediation", repos="http://cran.r-project.org")'

RUN cd /usr/local/bin && curl -fsSL https://genepi.qimr.edu.au/staff/manuelF/multivariate/plink.multivariate -o plink.multivariate && chmod a+x plink.multivariate 

RUN curl -fsSL http://statgen.us/files/2020/01/pleiotropy_final_datasets.zip -o pleiotropy.zip
RUN unzip pleiotropy.zip && mv pleiotropy_final_datasets/*  /home/jovyan/.work
RUN rm -rf pleiotropy*
RUN chown jovyan.users -R /home/jovyan

RUN curl -s -o /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/pull-tutorials/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh

RUN sed -i '2 i \
	pull-tutorial.sh pleiotropy & \
	'  /usr/local/bin/start-notebook.sh

USER jovyan