FROM gaow/base-notebook:1.0.0

LABEL maintainer="Diana Cornejo <dmc2245@cumc.columbia.edu>"

#Install plink==1.9 and R libraries
#Download Andrew's datasets from statgen.us 

USER root
     
RUN mkdir /home/jovyan/.work

RUN conda install -c bioconda plink && \
    R --slave -e 'install.packages("mediation", repos="http://cran.r-project.org")' && \
    R --slave -e "devtools::install_github('anastasia-lucas/hudson')"

# This URL has security measures preventing us from scripting this.  As a result, I've made a copy on statgen.us.
#RUN cd /usr/local/bin && curl -fsSL https://genepi.qimr.edu.au/staff/manuelF/multivariate/plink.multivariate.zip -o plink.multivariate.zip && unzip plink.multivariate.zip && rm plink.multivariate.zip && chmod a+x plink.multivariate 
RUN cd /usr/local/bin && curl -fsSL https://statgen.us/files/software/plink.multivariate/plink.multivariate.zip -o plink.multivariate.zip && unzip plink.multivariate.zip && rm plink.multivariate.zip && chmod a+x plink.multivariate 

RUN curl -so /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh

# Add notebook startup hook
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
RUN mkdir -p /usr/local/bin/start-notebook.d
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh pleiotropy &" > /usr/local/bin/start-notebook.d/get-updates.sh
RUN chmod a+x /usr/local/bin/start-notebook.d/get-updates.sh
# Users can type in "get-data" command in bash when they run the tutorial the first time, to download the data.
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh pleiotropy" > /usr/local/bin/get-data
RUN chmod a+x /usr/local/bin/get-data

RUN curl -fsSL https://statgen.us/files/2022/11/pleiotropy.zip -o pleiotropy.zip
RUN unzip pleiotropy.zip && mv pleiotropy/*  /home/jovyan/.work
RUN rm -rf pleiotropy*

RUN chown jovyan.users -R /home/jovyan

USER jovyan