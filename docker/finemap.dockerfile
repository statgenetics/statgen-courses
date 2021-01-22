FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo  <dmc2245@cumc.columbia.edu>
   
USER root

RUN R --slave -e 'remotes::install_github("stephenslab/susieR")' 
    
USER jovyan

# Download notebook script and clean up output in the notebook
RUN mkdir -p ~/.bin && echo "#!/bin/bash" > ~/.bin/pull-tutorial && chmod +x ~/.bin/pull-tutorial && echo "export PATH=$HOME/.bin:$PATH" >> $HOME/.bashrc
RUN echo ''' \
	mkdir -p ~/.cache && cd ~/.cache && \
	curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/notebooks/finemapping.ipynb -o finemapping.ipynb && \
	jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace finemapping.ipynb && \
	curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/finemapping.pdf -o finemapping.pdf && \
	mv *.* ~/work \
	''' >>  ~/.bin/pull-tutorial

