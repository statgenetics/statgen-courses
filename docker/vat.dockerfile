FROM gaow/base-notebook:latest

MAINTAINER Gao Wang <gw2411@columbia.edu>

USER root

# Install annovar package
RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y annovar && \
    apt-get clean

# Install companion tools PLINK and KING
RUN cd /tmp && wget http://people.virginia.edu/~wc9c/KING/executables/Linux-king224.tar.gz && \
	wget http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20191024.zip && \
	tar -zxvf Linux-king224.tar.gz && unzip plink_linux_x86_64_20191024.zip && \
	mv king plink /usr/local/bin && cd - && rm -rf /tmp/*

USER jovyan

# Install data used
# Notice that I packed annovar's humandb database in vat-data.tar.bz2 because
# annovar annotations keeps changing and are not version numbered so by bundling
# a snapshot of it with the data used in the tutorial we ensure reproducibility.
# The bundled version of data is obtained Oct 2019 using command:
# ./annotate_variation.pl -downdb -buildver hg19 -webfrom annovar refGene humandb
RUN curl -fsSL http://statgen.us/files/vat-cache.tar.bz2 -o vat-cache.tar.bz2 && tar jxvf vat-cache.tar.bz2 && rm -f vat-cache.tar.bz2
RUN curl -fsSL http://statgen.us/files/vat-data.tar.bz2 -o vat-data.tar.bz2 && tar jxvf vat-data.tar.bz2 && rm -f vat-data.tar.bz2

RUN mkdir -p $HOME/bin && ln -s /usr/lib/annovar/annotate_variation.pl $HOME/bin/annotate_variation.pl && echo "export PATH=\$HOME/bin:\$PATH" >> $HOME/.bashrc

# Install variant tools version 3.0.x
RUN conda install variant_tools==3.0.9 -c bioconda && \
   conda clean --all && rm -rf $HOME/.caches

# Update resource files to current VAT release
# This should be fine as I have excluded databases from
# including in `vat-cache.tar.bz2` as existing resources;
# changes made to other scripts should be backwards compatable and 
# not impact reproducibility.
RUN vtools admin --update_resource existing

# Download notebook script and clean up output in the notebook
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/notebooks/VAT.ipynb -o VAT.ipynb
RUN jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace VAT.ipynb
