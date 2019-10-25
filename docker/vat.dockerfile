FROM gaow/base-notebook:latest

MAINTAINER Gao Wang <gw2411@columbia.edu>

USER root

# Install dependency tools
RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y annovar statgen-king plink2 && \
    apt-get install -y swig && \
    apt-get clean

# Install data used
# Notice that I packed annovar's humandb database in vat-data.tar.bz2 because
# annovar annotations keeps changing and are not version numbered so by bundling
# a snapshot of it with the data used in the tutorial we ensure reproducibility:
# ./annotate_variation.pl -downdb -buildver hg19 -webfrom annovar refGene humandb
USER jovyan
RUN curl -fsSL http://statgen.us/files/vat-cache.tar.bz2 -o vat-cache.tar.bz2 && tar jxvf vat-cache.tar.bz2 && rm -f vat-cache.tar.bz2
RUN curl -fsSL http://statgen.us/files/vat-data.tar.bz2 -o vat-data.tar.bz2 && tar jxvf vat-data.tar.bz2 && rm -f vat-data.tar.bz2

RUN mkdir -p $HOME/bin && ln -s /usr/lib/annovar/annotate_variation.pl $HOME/bin/annotate_variation.pl && echo "export PATH=\$HOME/bin:\$PATH" >> $HOME/.bashrc

# Install variant tools version 2.7.2
RUN pip install https://github.com/vatlab/varianttools/archive/vtools-2.7.2.zip

# Download notebook script and clean up output in the notebook
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/notebooks/VAT.ipynb -o VAT.ipynb
RUN jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace VAT.ipynb
