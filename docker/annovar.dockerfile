FROM statgen-courses/docker

MAINTAINER Diana Cornejo <dmc2245@cumc.columbia.edu>

WORKDIR /root

#Install annovar package
RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y annovar && \
    apt-get clean

RUN mkdir -p $HOME/bin && ln -s /usr/lib/annovar/annotate_variation.pl $HOME/bin/annotate_variation.pl && echo "export PATH=\$HOME/bin:\$PATH" >> $HOME/.bashrc

## Update the exercise text
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/FunctionalAnnotation_exercise_2019.docx 


