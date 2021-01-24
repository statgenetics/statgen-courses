FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

#Install dependency tools and deploy data-set package that Carl made

USER root

RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get --allow-insecure-repositories update && \
    apt-get install -y annotation-tutorial && \
    apt-get clean

RUN curl -s -o /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/pull-tutorials/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh

# Insert this to the notebook startup script,
# https://github.com/jupyter/docker-stacks/blob/fad26c25b8b2e8b029f582c0bdae4cba5db95dc6/base-notebook/Dockerfile#L151
RUN sed -i '2 i \
    pull-tutorial.sh annovar & \
    copy-datasets.sh & \
    '  /usr/local/bin/start-notebook.sh

# Content for pull-tutorial.sh script
RUN echo "#!/bin/bash \n\
\n\
mkdir -p /tmp/.datacache \n\
cd /tmp/.datacache \n\
\n\
# Operations specific to this exercise. \n\
cp -r /home/shared/functional_annotation/* ./ \n\
ln -s work/humandb /home/jovyan/humandb \n\
\n\
chown -R jovyan.users * /home/jovyan \n\
mv * /home/jovyan/work \n\
cd \n\
rm -rf /tmp/.datacache \n\
" >  /usr/local/bin/copy-datasets.sh && chmod a+x /usr/local/bin/copy-datasets.sh

#Update the exercise text
USER jovyan
# ARG DUMMY=unknown
# RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/FunctionalAnnotation.2021.pdf -o FunctionalAnnotation.pdf
