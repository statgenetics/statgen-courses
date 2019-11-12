FROM gaow/base-notebook:1.0.0

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

USER root
#Install gemini with dependency tools, deploy data-set package
RUN wget https://raw.githubusercontent.com/arq5x/gemini/5db2e52ae4aee413a8780df538565c90a38e4b11/gemini/scripts/gemini_install.py && \	
    apt-get update && \
    apt-get clean && chown jovyan.users -R /home/jovyan/*

CMD python2 gemini_install.py /usr/local /usr/local/share/gemini && \
   export PATH=$PATH:/usr/local/gemini/bin	

#Update the exercise text
USER jovyan
ARG DUMMY=unknown
 
