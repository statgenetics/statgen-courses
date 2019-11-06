FROM gaow/base-notebook:latest

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

USER root

#Install dependency tools and install data-set using Carl's deb packages

RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
apt-get update && \
    apt-get install -y popgen-tutorial && \
    apt-get clean && mv /home/shared/* /home/jovyan && chown jovyan.users -R /home/jovyan/*

#Download scripts and tutorial files

USER jovyan
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PopGen.docx -o PopGen.docx
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PopGen.pp.docx -o PopGen.pp.docx
RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PopGen.pp.pdf -o PopGen.pp.pdf
RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PopGen.sim.docx -o PopGen.sim.docx
RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PopGen.sim.noscript.docx -o PopGen.sim.noscript.docx
RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PopGen.sim.noscript.pdf -o PopGen.sim.noscript.pdf
RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/PopGen.sim.pdf -o PopGen.sim.pdf
RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/code/popgen_drift.R -o popgen_drift.R
RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/code/popgen_selection.R -o popgen_selection.R
