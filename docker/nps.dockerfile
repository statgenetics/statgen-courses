FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo  <dmc2245@cumc.columbia.edu>

USER root

#Install and compile NPS1.1
#Install associated R packages

RUN curl -fsSL https://github.com/sgchun/nps/archive/1.1.tar.gz -o nps-1.1.tar.gz && tar -zxvf nps-1.1.tar.gz && rm -f nps-1.1.tar.gz &&  cd nps-1.1/ && make
RUN cd nps-1.1/ &&  Rscript -e 'install.packages("pROC", repos="http://cran.r-project.org")' && Rscript -e 'install.packages("DescTools", repos="http    ://cran.r-project.org")'
#RUN mv nps-1.1/ /home/jovyan

# Update ubuntu

RUN apt-get update && \
    apt-get clean

# Download NPS test data and place ir under testdata/ folder

USER jovyan
RUN cd nps-1.1/testdata/
RUN curl -fsSL http://statgen.us/files/NPS.Test1.tar.gz -o NPS.Test1.tar.gz && \
    tar -zxvf NPS.Test1.tar.gz &&\
    rm -f NPS.Test1.tar.gz
RUN cd ..

# Download notebook script and clean up output in the notebook
#ARG DUMMY=unknown
#RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/notebooks/VAT.ipynb -o VAT.ipynb
#RUN jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace VAT.ipynb
#RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/VAT.doc -o VAT.doc
