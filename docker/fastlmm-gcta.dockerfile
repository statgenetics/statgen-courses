FROM gaow/base-notebook:1.0.0

LABEL maintainer="Diana Cornejo <dmc2245@cumc.columbia.edu>"

#Install dependecy tools for fastlmm the binary executable from microsoft was used
#gcta.v.1.26.0 installed with conda
#download datasets from Heather Cordell uploaded to statgen.us

USER root

RUN mkdir -p /home/jovyan/.work
		
RUN mkdir -p /tmp/plink1.90 && cd /tmp/plink1.90 && \
    wget -q http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20200219.zip && \
    unzip plink_linux_x86_64_20200219.zip && \
    cp plink /usr/local/bin && \
    rm -rf /tmp/plink1.90

# RUN cd /tmp && \
#     curl -so gcta.zip https://cnsgenomics.com/software/gcta/bin/gcta_1.93.2beta.zip && \
#     unzip gcta.zip && \
#     mv gcta_1.93.2beta/gcta64 /usr/local/bin && \
#     chmod a+x /usr/local/bin/gcta64 && \
#     cd - && \
#     rm -rf /tmp/*

RUN cd /tmp && \
    curl -so - http://statgen.us/files/gcta-1.93.2beta.tar.xz | tar Jx && \
    mv gcta-1.93.2beta/gcta64 /usr/local/bin && \
    chmod a+x /usr/local/bin/gcta64 && \
    rm -rf gcta-1.93.2beta

RUN cd /tmp && \
    curl -so FaSTLMM.zip https://download.microsoft.com/download/B/0/9/B095C9A0-C08B-41F7-9C7E-76097E875235/FaSTLMM.207.zip && \
    unzip FaSTLMM.zip && \
    mv FaSTLMM.207c/Bin/Linux_MKL/fastlmmc /usr/local/bin && \
    chmod a+x /usr/local/bin/fastlmmc && \
    cd - && \
    rm -rf /tmp/*

RUN cd /tmp && \
    curl -so BoltLMM.tar.gz https://storage.googleapis.com/broad-alkesgroup-public/BOLT-LMM/downloads/BOLT-LMM_v2.3.4.tar.gz && \
    tar zxvf BoltLMM.tar.gz && \
    mv BOLT-LMM_v2.3.4/bolt /usr/local/bin && \
    chmod a+x /usr/local/bin/bolt && \
    mv BOLT-LMM_v2.3.4/lib/* /usr/lib && \
    mv BOLT-LMM_v2.3.4/tables /home/jovyan && \
    cd - && \
    rm -rf /tmp/*


RUN curl -so /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh

# Add notebook startup hook
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
RUN mkdir -p /usr/local/bin/start-notebook.d
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh fastlmm-gcta &" > /usr/local/bin/start-notebook.d/get-updates.sh
RUN chmod a+x /usr/local/bin/start-notebook.d/get-updates.sh

RUN chown jovyan.users -R /home/jovyan

USER jovyan

RUN curl -so PRACDATA.zip http://statgen.us/files/2020/01/PRACDATA.zip && \
    unzip PRACDATA.zip && \
    (cd PRACDATA && rm -rf sim* cassi plink gcta64 fastlmmc ) && \ 
    mv PRACDATA/* /home/jovyan/.work && \
    rm -rf PRACDATA*
