FROM gaow/base-notebook:1.0.0

LABEL maintainer="Diana Cornejo <dmc2245@cumc.columbia.edu>"

USER root

RUN apt-get --allow-insecure-repositories update && \
    apt-get install curl make gcc g++ libreadline-dev \
    libz-dev libbz2-dev liblzma-dev libpcre3-dev libssl-dev libcurl4-openssl-dev \
    libopenblas-dev default-jre unzip libboost-all-dev \
    libpng-dev libcairo2-dev tabix --yes && \
    apt-get clean
   
#Install and compile NPS.1.1.0
#Install associated R packages
#Download NPS test data and place it under testdata/ folder

RUN Rscript -e 'install.packages("pROC", repos="http://cran.r-project.org")' && \
    Rscript -e 'install.packages("DescTools", repos="http://cran.r-project.org")'

RUN mkdir /home/jovyan/.work

RUN curl -fsSL https://github.com/sgchun/nps/archive/1.1.0.tar.gz -o nps-1.1.0.tar.gz && \
    tar xvzf nps-1.1.0.tar.gz && \
    rm -rf nps-1.1.0.tar.gz && \
    cd nps-1.1.0/ && \
    make && \
    cd testdata/ && \
    curl -fsSL https://statgen.us/files/NPS.Test1.tar.gz -o NPS.Test1.tar.gz && \
    tar xvzf NPS.Test1.tar.gz && \
    rm -rf NPS.Test1.tar.gz

RUN mv nps-1.1.0 /home/jovyan/.work/nps

RUN curl -so /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh

RUN sed -i '2 i \
	pull-tutorial.sh nps & \
	'  /usr/local/bin/start-notebook.sh

USER jovyan
