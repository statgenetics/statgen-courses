FROM gaow/base-notebook:1.0.0

LABEL maintainer="Diana Cornejo <dmc2245@cumc.columbia.edu>"

#Install dependency tools and deploy data-set package that Carl made

USER root

RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get --allow-insecure-repositories update && \
    apt-get install -y annotation-tutorial && \
    apt-get clean



# RUN curl -s -o /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN curl -s -o /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/pull-tutorials/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh
    
# Add notebook startup hook
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
RUN mkdir -p /usr/local/bin/start-notebook.d
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh annovar\n/usr/local/bin/copy-datasets.sh" > /usr/local/bin/start-notebook.d/get-updates.sh
RUN chmod a+x /usr/local/bin/start-notebook.d/get-updates.sh

# Content for copy-datasets.sh script
RUN echo "#!/bin/bash \n\
\n\
mkdir -p /tmp/.datacache \n\
cd /tmp/.datacache \n\
\n\
# Operations specific to this exercise. \n\
cp -r /home/shared/functional_annotation/* ./ \n\
ln -s ../humandb /home/jovyan/work/humandb \n\
\n\
chown -R jovyan.users * /home/jovyan \n\
mv * /home/jovyan/work \n\
cd \n\
rm -rf /tmp/.datacache \n\
" >  /usr/local/bin/copy-datasets.sh && chmod a+x /usr/local/bin/copy-datasets.sh

#Update the exercise text
USER jovyan