FROM gaow/base-notebook:1.0.0

LABEL maintainer="Diana Cornejo <dmc2245@cumc.columbia.edu>"

USER root

RUN mkdir /home/jovyan/.work

RUN curl -fsSL https://bitbucket.org/statgen/plinkseq/get/5d071291075c.zip -o plinkseq.zip && unzip plinkseq.zip && mv statgen-plinkseq* plinkseq && cd plinkseq && make && rm -f build/execs/*.o && rm -f build/execs/*.dep && mv build/execs/* /usr/local/bin && cd - && rm -rf plinkseq*

RUN curl -s -o /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/pull-tutorials/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh
    
# Insert this to the notebook startup script,
# https://github.com/jupyter/docker-stacks/blob/fad26c25b8b2e8b029f582c0bdae4cba5db95dc6/base-notebook/Dockerfile#L151
RUN sed -i '2 i \
	( pull-tutorial.sh pseq  && convert-ipynb.sh ) & \
	'  /usr/local/bin/start-notebook.sh

# Content for convert-ipynb.sh.sh script
RUN echo "#!/bin/bash \n\
cd /home/jovyan/work \n\
jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace PSEQ.ipynb \n\
chown -R jovyan.users * \n\
" >>  /usr/local/bin/convert-ipynb.sh


USER jovyan

# Download data

RUN cd /home/jovyan/.work
RUN curl -fsSL http://statgen.us/files/plinkseq-data.tar.bz2 -o plinkseq-data.tar.bz2 && tar jxvf plinkseq-data.tar.bz2 && rm -f plinkseq-data.tar.bz2