FROM gaow/base-notebook:1.0.0

LABEL Diana Cornejo <dmc2245@cumc.columbia.edu>

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

USER root

RUN Rscript -e 'p = c("data.table", "bigsnpr"); install.packages(p, repos="https://cloud.r-project.org")'

RUN wget http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20201019.zip && \
    unzip plink_linux_x86_64_20201019.zip && \
    mv plink prettify /usr/local/bin

USER jovyan
RUN mkdir -p /home/jovyan/.work
RUN cd /home/jovyan/.work && wget https://raw.githubusercontent.com/cumc/bioworkflows/master/ldpred/ldpred.ipynb
RUN cd /home/jovyan/.work && curl -fsSL http://statgen.us/files/2021/01/ldpred2.tar.gz -o ldpred2.tar.gz && tar -xzvf ldpred2.tar.gz && rm -rf *.tar.gz
