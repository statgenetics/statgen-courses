FROM gaow/base-notebook:1.3.0

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

#Install dependency tools and deploy data-set package that Carl made

USER root

RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get --allow-insecure-repositories update && \
    apt-get install -y annotation-tutorial && \
    apt-get clean && mv /home/shared/functional_annotation/* /home/jovyan && rm -rf /home/shared && chown jovyan.users -R /home/jovyan/*

#Update the exercise text
USER jovyan
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/FunctionalAnnotation.2021.pdf -o FunctionalAnnotation.pdf
