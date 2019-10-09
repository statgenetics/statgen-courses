FROM gaow/base-notebook:latest

MAINTAINER Gao Wang <gw2411@columbia.edu>

USER root

RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y annovar annovar-humandb statgen-king && \ 
    apt-get clean

# Install variant tools
# https://github.com/vatlab/varianttools/blob/master/development/docker/Dockerfile

RUN wget http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.10.5.tar.gz \
 && tar -zxvf hdf5-1.10.5.tar.gz \
 && cd hdf5-1.10.5 \
 && ./configure --prefix=/usr/local --enable-build-mode=production --enable-threadsafe --disable-hl \
 && make -j4 \
 && make install \
 && make clean

RUN wget http://download.zeromq.org/zeromq-4.0.3.tar.gz \
  && tar -zxvf zeromq-4.0.3.tar.gz 

RUN wget -O boost_1_49_0.tar.gz "http://downloads.sourceforge.net/project/boost/boost/1.49.0/boost_1_49_0.tar.gz?r=&ts=1435893980&use_mirror=iweb" \
 && tar -xf boost_1_49_0.tar.gz boost_1_49_0/boost boost_1_49_0/libs/iostreams boost_1_49_0/libs/regex boost_1_49_0/libs/filesystem boost_1_49_0/libs/detail boost_1_49_0/libs/system 

RUN conda install cython pytables scipy && \
    conda clean --all && rm -rf /tmp/* $HOME/.caches

RUN curl -fsSL https://github.com/vatlab/varianttools/archive/v3.0.3.zip -o vtools.zip \
    && unzip vtools.zip && cd varianttools-3.0.3 && mv /zeromq-4.0.3 ./src && mv /boost_1_49_0 ./src \
    && python setup.py install && cd .. && rm -rf vtools.zip varianttools-3.0.3

# https://community.paperspace.com/t/storage-and-h5py-pytables-e-g-keras-save-weights-issues-heres-why-and-how-to-solve-it/430
# HDF5 locking issues
ENV     HDF5_USE_FILE_LOCKING FALSE

USER jovyan

RUN curl -fsSL http://statgen.us/files/vat.tar.bz2 -o vat.tar.bz2 && tar jxvf vat.tar.bz2 && rm -f vat.tar.bz2
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/notebooks/VAT.ipynb -o VAT.ipynb
RUN jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace VAT.ipynb