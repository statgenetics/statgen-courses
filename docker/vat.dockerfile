FROM gaow/base-notebook:1.0.0

LABEL maintainer="Diana Cornejo <dmc2245@cumc.columbia.edu>"

USER root

RUN mkdir /home/jovyan/.work

RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 
# Problem using letsencrypt for staten.us and a solution
# https://stackoverflow.com/questions/69401972/refresh-lets-encrypt-root-ca-in-docker-container
RUN sed -i 's/mozilla\/DST_Root_CA_X3.crt/!mozilla\/DST_Root_CA_X3.crt/g' /etc/ca-certificates.conf
RUN update-ca-certificates
# Install annovar package
RUN echo "deb [trusted=yes] https://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get --allow-insecure-repositories update && \
    apt-get install -y annovar && \
    apt-get clean

# Install companion tools PLINK and KING
RUN cd /tmp && \
  curl -so - wget https://www.kingrelatedness.com/executables/Linux-king224.tar.gz | tar zx && \
  wget http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20191024.zip && unzip plink_linux_x86_64_20191024.zip && \
  mv king plink /usr/local/bin && cd - && rm -rf /tmp/*

RUN curl -so /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /usr/local/bin/pull-tutorial.sh

# Add notebook startup hook
# https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
RUN mkdir -p /usr/local/bin/start-notebook.d
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh vat &" > /usr/local/bin/start-notebook.d/get-updates.sh
RUN chmod a+x /usr/local/bin/start-notebook.d/get-updates.sh
# Users can type in "get-data" command in bash when they run the tutorial the first time.
RUN echo "#!/bin/bash\n/usr/local/bin/pull-tutorial.sh vat" > /usr/local/bin/get-data
RUN chmod a+x /usr/local/bin/get-data

RUN chown -R jovyan.users /home/jovyan
USER jovyan

# Install data used
# Notice that I packed annovar's humandb database in vat-data.tar.bz2 because
# annovar annotations keeps changing and are not version numbered so by bundling
# a snapshot of it with the data used in the tutorial we ensure reproducibility.
# The bundled version of data is obtained Oct 2019 using command:
# ./annotate_variation.pl -downdb -buildver hg19 -webfrom annovar refGene humandb
RUN curl -so - https://statgen.us/files/vat-cache.tar.bz2 | tar jx
RUN ( cd $HOME/.work && curl -so - https://statgen.us/files/vat-data.tar.bz2 | tar jx )
RUN mv $HOME/.work/bin $HOME/bin && \
  ln -s /usr/lib/annovar/annotate_variation.pl $HOME/bin/annotate_variation.pl && \
  echo "export PATH=\$HOME/bin:\$PATH" >> $HOME/.bashrc

# Install variant tools version 3.x
RUN conda install variant_tools==3.1.3 -c bioconda -c conda-forge && \
    conda clean --all && rm -rf $HOME/.caches

# Update resource files to current VAT release
# This should be fine as I have excluded databases from
# including in `vat-cache.tar.bz2` as existing resources;
# changes made to other scripts should be backwards compatable and 
# not impact reproducibility.
RUN vtools admin --update_resource existing
