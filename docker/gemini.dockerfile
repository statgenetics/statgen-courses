FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

USER root
# GEMINI installer needs anaconda 2 environment; only python 2.7 is not enough
# Also install vt for VCF decomposition, VEP for annotation
RUN conda create --name py2 python=2.7
RUN bash -c "source activate py2 && conda install --yes -c conda-forge -c bioconda gemini=0.30.2-0 vt=2015.11.10-3 variant-effect-predictor=87-0"
 
USER jovyan
# Download datafiles
RUN curl -fsSL http://statgen.us/files/2017/09/data/gemini.tar.gz -o gemini.tar.gz && tar zxvf gemini.tar.gz && rm -f gemini.tar.gz  
# Update the exercise text
RUN echo "source activate py2" >> $HOME/.bashrc
RUN mkdir -p $HOME/.gemini $HOME/annotation_db && echo "annotation_dir: $HOME/annotation_db" > $HOME/.gemini/gemini-config.yaml
RUN printf "This folder is meant for gemini annotation resource databases,\nas is configured in ~/.gemini/gemini-config.yaml\nThese annotations were used along with VCF files as input to generate the database files in the tutorial." > $HOME/annotation_db/README.md
ARG DUMMY=unknown
RUN curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/Gemini.docx -o Gemini.docx
