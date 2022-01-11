FROM gaow/base-notebook:1.0.0

LABEL maintainer="Diana Cornejo <dmc2245@cumc.columbia.edu>"

USER root

RUN mkdir /home/jovyan/.work

RUN curl -so plinkseq.zip https://bitbucket.org/statgen/plinkseq/get/5d071291075c.zip && \
  unzip plinkseq.zip && \
  mv statgen-plinkseq* plinkseq && \
  cd plinkseq && \
  make && \
  rm -f build/execs/*.o build/execs/*.dep && \
  mv build/execs/* /usr/local/bin && \
  cd - && \
  rm -rf plinkseq*

RUN curl -so /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh

# Add notebook startup hook
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
RUN mkdir -p /usr/local/bin/start-notebook.d
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh README" > /usr/local/bin/start-notebook.d/get-updates.sh
RUN chmod a+x /usr/local/bin/start-notebook.d/get-updates.sh
# Users can type in "get-data" command in bash when they run the tutorial the first time, to download the data.
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh pseq" > /usr/local/bin/get-data
RUN chmod a+x /usr/local/bin/get-data

RUN chown jovyan.users -R /home/jovyan

USER jovyan
# Download data

RUN cd /home/jovyan/.work && curl -so - https://statgen.us/files/plinkseq-data.tar.bz2 | tar jx