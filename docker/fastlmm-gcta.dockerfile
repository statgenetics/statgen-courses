FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo  <dmc2245@cumc.columbia.edu>

USER root
   
#Install dependecy tools using conda with  python=2.7 for fastlmm and python=3.7 for gcta.v.1.26.0
#download datasets from Heather Cordell uploaded to statgen.us
     
RUN apt-get update && \
    apt-get clean
		
RUN conda install --yes -c bioconda -c biobuilds plink gcta==1.26.0 && \
    conda create --name py2 python=2.7 
RUN bash -c "source activate py2 && conda install --yes -c bioconda fastlmm==0.2.32" && \
    conda clean --all 
 
RUN curl -fsSL http://statgen.us/files/2020/01/PRACDATA.zip -o PRACDATA.zip && \
    unzip PRACDATA.zip && \
    mv PRACDATA/* /home/jovyan && rm -rf PRACDAT* && \
    rm -rf sim* cassi plink fastlmmc gcta64 && \ 
    chown jovyan.users -R /home/jovyan/*

USER jovyan

ARG DUMMY=unknown

RUN curl -fsSL https://github.com/statgenetics/statgen-courses/blob/master/handout/FASTLMM-NY2020.pdf -o FASTLMM.pdf
RUN curl -fsSL https://github.com/statgenetics/statgen-courses/blob/master/handout/GCTA-NY2020.pdf -o GCTA.pdf
