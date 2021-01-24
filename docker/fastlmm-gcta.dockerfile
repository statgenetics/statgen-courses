FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo  <dmc2245@cumc.columbia.edu>

#Install dependecy tools for fastlmm the binary executable from microsoft was used
#gcta.v.1.26.0 installed with conda
#download datasets from Heather Cordell uploaded to statgen.us

USER root
		
# RUN conda install --yes -c bioconda plink

RUN mkdir -p /home/jovyan/.work

RUN mkdir -p /tmp/plink1.90 && cd /tmp/plink1.90 && \
    wget -q http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20200219.zip && \
    unzip plink_linux_x86_64_20200219.zip && \
    cp plink /usr/local/bin && \
    rm -rf /tmp/plink1.90

RUN cd /tmp && \
    curl -fsSL https://cnsgenomics.com/software/gcta/bin/gcta_1.93.2beta.zip -o gcta.zip && \
    unzip gcta.zip && \
    mv gcta_1.93.2beta/gcta64 /usr/local/bin && \
    chmod a+x /usr/local/bin/gcta64 && \
    cd - && \
    rm -rf /tmp/*

RUN cd /tmp && \
    curl -fsSL https://download.microsoft.com/download/B/0/9/B095C9A0-C08B-41F7-9C7E-76097E875235/FaSTLMM.207.zip -o FaSTLMM.zip && \
    unzip FaSTLMM.zip && \
    mv FaSTLMM.207c/Bin/Linux_MKL/fastlmmc  /usr/local/bin && \
    chmod a+x /usr/local/bin/fastlmmc && \
    cd - && \
    rm -rf /tmp/*

RUN curl -fsSL http://statgen.us/files/2020/01/PRACDATA.zip -o PRACDATA.zip && \
    unzip PRACDATA.zip && \
    mv PRACDATA/* /home/jovyan/.work && rm -rf PRACDATA* && \
    rm -rf sim* cassi plink gcta64 fastlmmc && \ 
    chown jovyan.users -R /home/jovyan


RUN curl -s -o /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/pull-tutorials/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh

RUN sed -i '2 i \
	pull-tutorial.sh fastlmm-gcta & \
	'  /usr/local/bin/start-notebook.sh

USER jovyan

ARG DUMMY=unknown