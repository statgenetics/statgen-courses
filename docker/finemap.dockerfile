FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo  <dmc2245@cumc.columbia.edu>
   
USER root

RUN R --slave -e 'remotes::install_github("stephenslab/susieR")' 
RUN R --slave -e 'install.packages("corrplot")' 
    
# Insert this to the notebook startup script,
# https://github.com/jupyter/docker-stacks/blob/fad26c25b8b2e8b029f582c0bdae4cba5db95dc6/base-notebook/Dockerfile#L151
RUN sed -i '2 i \
	pull-tutorial.sh \
	'  /usr/local/bin/start-notebook.sh

# Content for pull-tutorial.sh script
RUN echo "#!/bin/bash" > /usr/local/bin/pull-tutorial.sh && chmod +x /usr/local/bin/pull-tutorial.sh
RUN echo ''' \
	mkdir -p /tmp/.cache && cd /tmp/.cache && \
	curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/notebooks/finemapping.ipynb -o finemapping.ipynb && \
	curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/notebooks/finemapping_answers.ipynb -o finemapping_answers.ipynb && \
	jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace finemapping.ipynb && \
	chown -R jovyan.users *.* && mv *.* /home/jovyan/work \
	''' >>  /usr/local/bin/pull-tutorial.sh

USER jovyan
