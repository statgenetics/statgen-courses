FROM gaow/base-notebook:1.0.0

LABEL maintainer="Diana Cornejo <dmc2245@cumc.columbia.edu>"
   
#Install dependecy tools and download datasets

USER root     
RUN conda install -y -c bioconda plink
RUN R --slave -e "install.packages('BiocManager'); BiocManager::install('multtest')"

RUN curl -so /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh

RUN mkdir -p $HOME/.work
RUN for f in berlin_2022_all_nothnagel GWAS_part1 GWAS_part2; do ( cd $HOME/.work && curl -so - https://statgen.us/files/$f.tar.gz | tar zx ); done
RUN chown jovyan.users -R $HOME/.work

# Add notebook startup hook
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
RUN mkdir -p /usr/local/bin/start-notebook.d
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh plink-r-nothnagel &" > /usr/local/bin/start-notebook.d/get-updates.sh
RUN chmod a+x /usr/local/bin/start-notebook.d/get-updates.sh

# Users can type in "get-data" command in bash when they run the tutorial the first time, to download the data.
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh plink-r-nothnagel" > /usr/local/bin/get-data
RUN chmod a+x /usr/local/bin/get-data

USER jovyan
