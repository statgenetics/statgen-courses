FROM gaow/base-notebook:1.0.0

LABEL maintainer="Diana Cornejo <dmc2245@cumc.columbia.edu>"
   
#Install dependecy tools and download datasets

USER root

RUN mkdir /home/jovyan/.work
     
RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get --allow-insecure-repositories update && \
    apt-get install -y plink-tutorial && \
    conda install -y -c bioconda plink && \	
    apt-get clean
    
RUN mv /home/shared/* /home/jovyan/.work/

RUN chown jovyan.users -R /home/jovyan

RUN curl -s -o /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/pull-tutorials/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh

RUN sed -i '2 i \
	pull-tutorial.sh plink & \
	'  /usr/local/bin/start-notebook.sh

USER jovyan
