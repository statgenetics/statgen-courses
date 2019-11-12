FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

USER root
#Update packages and give permisions to jovyan
RUN apt-get update && \
    apt-get clean && chown jovyan.users -R /home/jovyan/* && \

#Install gemini with dependency tools, deploy data-set package
RUN cd /tmp &&  wget https://www.python.org/ftp/python/2.7.17/Python-2.7.17.tgz
    tar -zxvf Python-2.7.17.tgz && \ 
    cd Python-2.7.17 && ./configure --enable-optimizations && make altinstall && \
    wget https://raw.githubusercontent.com/arq5x/gemini/5db2e52ae4aee413a8780df538565c90a38e4b11/gemini/scripts/gemini_install.py && \	
    mv gemini_install.py Python-2.7.17 /usr/local/bin && cd - && rm -rf /tmp/*

RUN cd /usr/local/bin && \
    python gemini_install.py /usr/local /usr/local/share/gemini && \
    echo "export PATH=\$HOME/bin/gemini:\$PATH" >> $HOME/.bashrc

#Update the exercise text
USER jovyan
ARG DUMMY=unknown
 
