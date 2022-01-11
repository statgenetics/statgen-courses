FROM gaow/base-notebook

LABEL maintainer="Diana Cornejo <dmc2245@cumc.columbia.edu>"
   
USER root

RUN mkdir -p /home/jovyan/.work

RUN R --slave -e 'remotes::install_github("stephenslab/susieR")' 
RUN R --slave -e 'install.packages("corrplot")'

RUN curl -so /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh

RUN mkdir -p /home/jovyan/.work

# Add notebook startup hook
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
RUN mkdir -p /usr/local/bin/start-notebook.d
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh finemap &" > /usr/local/bin/start-notebook.d/get-updates.sh
RUN chmod a+x /usr/local/bin/start-notebook.d/get-updates.sh
# Users can type in "get-data" command in bash when they run the tutorial the first time, to download the data.
RUN echo "#!/bin/bash\n/opt/pull-tutorial.sh finemap" > /usr/local/bin/get-data
RUN chmod a+x /usr/local/bin/get-data

RUN chown jovyan.users -R /home/jovyan

USER jovyan
