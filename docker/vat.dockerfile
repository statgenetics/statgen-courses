FROM gaow/base-notebook:latest

MAINTAINER Gao Wang <gw2411@columbia.edu>

USER root

# Install dependency tools
RUN echo "deb [trusted=yes] http://statgen.us/deb ./" | tee -a /etc/apt/sources.list.d/statgen.list && \
    apt-get update && \
    apt-get install -y annovar annovar-humandb statgen-king plink && \
    apt-get clean

RUN ln -s /usr/bin/plink1 /usr/local/bin/plink

# https://github.com/vatlab/varianttools/blob/master/development/docker/Dockerfile

RUN curl -fsSL -o hdf5-1.10.5.tar.gz http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.10.5.tar.gz \
 && tar -zxvf hdf5-1.10.5.tar.gz \
 && cd hdf5-1.10.5 \
 && ./configure --prefix=/usr/local --enable-build-mode=production --enable-threadsafe --disable-hl \
 && make -j4 \
 && make install \
 && cd .. && rm -rf hdf5-1.10.5.tar.gz hdf5-1.10.5


RUN curl -fsSL -o zeromq-4.0.3.tar.gz http://download.zeromq.org/zeromq-4.0.3.tar.gz \
  && tar -zxvf zeromq-4.0.3.tar.gz && rm -f zeromq-4.0.3.tar.gz

RUN curl -fsSL -o boost_1_49_0.tar.gz "http://downloads.sourceforge.net/project/boost/boost/1.49.0/boost_1_49_0.tar.gz?r=&ts=1435893980&use_mirror=iweb" \
 && tar -xf boost_1_49_0.tar.gz boost_1_49_0/boost boost_1_49_0/libs/iostreams boost_1_49_0/libs/regex boost_1_49_0/libs/filesystem boost_1_49_0/libs/detail boost_1_49_0/libs/system \
 && rm -f boost_1_49_0.tar.gz

RUN conda install cython pytables scipy && \
    conda clean --all && rm -rf /tmp/* $HOME/.caches

# Download data and notebook script
USER jovyan
RUN curl -fsSL http://statgen.us/files/vat-cache.tar.bz2 -o vat-cache.tar.bz2 && tar jxvf vat-cache.tar.bz2 \
    && rm -f vat-cache.tar.bz2 && rm -rf .variant_tools/.runtime .vtools_cache/.runtime
RUN curl -fsSL http://statgen.us/files/vat-data.tar.bz2 -o vat-data.tar.bz2 && tar jxvf vat-data.tar.bz2 && rm -f vat-data.tar.bz2

# Install variant tools from source code
# Do it here to make future version updates easier
USER root
# https://community.paperspace.com/t/storage-and-h5py-pytables-e-g-keras-save-weights-issues-heres-why-and-how-to-solve-it/430
# HDF5 locking issues
ENV HDF5_USE_FILE_LOCKING FALSE
RUN curl -fsSL https://github.com/vatlab/varianttools/archive/v3.0.3.zip -o vtools.zip \
    && unzip -qq vtools.zip && cd varianttools-3.0.3 && mv ../zeromq-4.0.3 ./src && mv ../boost_1_49_0 ./src \
    && python setup.py install && cd .. && rm -rf vtools.zip varianttools-3.0.3

# Download notebook script and clean up output in the notebook
USER jovyan
ENV HDF5_USE_FILE_LOCKING FALSE
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/notebooks/VAT.ipynb -o VAT.ipynb
RUN jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace VAT.ipynb