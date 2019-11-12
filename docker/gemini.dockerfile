FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

USER root
#Update packages and give permisions to jovyan
RUN apt-get update && \
    apt-get install -y python2.7 python2.7-dev && \
    apt-get clean

RUN curl -fsSL https://raw.githubusercontent.com/arq5x/gemini/5db2e52ae4aee413a8780df538565c90a38e4b11/gemini/scripts/gemini_install.py -o /tmp/gemini_install.py && \
    python2.7 /tmp/gemini_install.py /usr/local /usr/local/share/gemini && rm -rf /tmp/*

#Update the exercise text
USER jovyan
RUN echo "export PATH=/usr/local/gemini/bin:\$PATH" >> $HOME/.bashrc
ARG DUMMY=unknown
