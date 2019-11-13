FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

USER root
# GEMINI installer needs anaconda 2 environment; only python 2.7 is not enough
RUN conda create --name py2 python=2.7
RUN bash -c "source activate py2 && conda install --yes -c conda-forge -c bioconda gemini=0.30.2-0"
 
USER jovyan

# Download datafiles
RUN curl -fsSL http://statgen.us/files/2017/09/data/gemini.tar.gz -o gemini.tar.gz && tar jxvf gemini.tar.gz && rm -f gemini.tar.gz  

# Update the exercise text
RUN echo "source activate py2" >> $HOME/.bashrc
RUN mkdir -p $HOME/.gemini $HOME/gemini-data && echo "annotation_dir: $HOME/gemini-data" > $HOME/.gemini/gemini-config.yaml
ARG DUMMY=unknown
