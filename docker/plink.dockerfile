FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo  <dmc2245@cumc.columbia.edu>

USER root
   
#Install dependecy tools and download datasets
     
RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y plink-tutorial && \
    apt-get clean && mv /home/shared/* /home/jovyan && rm -rf /home/shared && chown jovyan.users -R /home/jovyan/*

USER jovyan

ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://github.com/statgenetics/statgen-courses/tree/master/handout/PLINK_data_qc.docx -o Plink_data_qc.docx
RUN curl -fsSL https://github.com/statgenetics/statgen-courses/tree/master/handout/PLINK_Substructure.docx  -o Plink_substructure.docx

