FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo  <dmc2245@cumc.columbia.edu>

#Install dependecy tools for fastlmm the binary executable from microsoft was used
#gcta.v.1.26.0 installed with conda
#download datasets from Heather Cordell uploaded to statgen.us

USER root
		
RUN conda install --yes -c bioconda plink

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
    mv PRACDATA/* /home/jovyan && rm -rf PRACDAT* && \
    rm -rf sim* cassi plink gcta64 fastlmmc && \ 
    chown jovyan.users -R /home/jovyan/*

USER jovyan

ARG DUMMY=unknown

RUN wget  https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/FASTLMM.pdf && \
    wget  https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/GCTA.pdf
