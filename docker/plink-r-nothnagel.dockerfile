FROM gaow/base-notebook:1.0.0

LABEL maintainer="Diana Cornejo <dmc2245@cumc.columbia.edu>"
   
#Install dependecy tools and download datasets

USER root     
RUN conda install -y -c bioconda plink

RUN curl -so /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh

# Users can type in "get-data" command in bash when they run the tutorial the first time, to download the data.
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh plink-r-nothnagel" > /usr/local/bin/get-data
RUN chmod a+x /usr/local/bin/get-data

RUN chown jovyan.users -R /home/jovyan

USER jovyan
