FROM gaow/base-notebook:1.3.0

MAINTAINER Diana Cornejo  <dmc2245@cumc.columbia.edu>
   
USER root

RUN R --slave -e 'remotes::install_github("stephenslab/susieR")' 
    
USER jovyan

# Download notebook script and clean up output in the notebook
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/notebooks/finemapping.ipynb -o finemapping.ipynb
RUN jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace finemapping.ipynb
RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/finemapping.pdf -o finemapping.pdf

