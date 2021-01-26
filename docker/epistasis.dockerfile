FROM gaow/base-notebook:1.0.0

LABEL maintainer="Diana Cornejo <dmc2245@cumc.columbia.edu>"

#Install dependecy tools and download datasets

USER root

RUN mkdir /home/jovyan/.work
     
RUN apt-get --allow-insecure-repositories update && \
    apt-get install g++ && \		
    conda install -c bioconda plink && \
    apt-get clean

RUN curl -fsSL https://www.staff.ncl.ac.uk/richard.howey/cassi/cassi-v2.51-code.zip -o cassi.zip && \
    unzip cassi.zip && cd cassi-v2.51-code && g++ -m64 -O3 *.cpp -o cassi && mv cassi /usr/local/bin && cd - && rm -rf cass*


RUN curl -so /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh

# Add notebook startup hook
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
RUN mkdir -p /usr/local/bin/start-notebook.d
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh epistasis &" > /usr/local/bin/start-notebook.d/get-updates.sh
RUN chmod a+x /usr/local/bin/start-notebook.d/get-updates.sh

RUN chown jovyan.users -R /home/jovyan

USER jovyan

RUN curl -so PRACDATA.zip http://statgen.us/files/2020/01/PRACDATA.zip && \
  unzip PRACDATA.zip && \
  mv PRACDATA/simcasecon.* /home/jovyan/.work && \
  rm -rf PRACDATA*