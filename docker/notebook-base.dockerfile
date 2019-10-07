FROM jupyter/base-notebook:a97a294194ab

MAINTAINER Gao Wang <gw2411@columbia.edu>

USER root

WORKDIR /tmp

# Tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    ca-certificates \
    build-essential \
    gfortran \
    libgfortran-6-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libsqlite3-dev \
    libxml2-dev \
    libssh2-1-dev \
    libc6-dev \
    libgomp1 \
    libatlas3-base \
    && apt-get install graphviz pandoc software-properties-common nodejs npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

RUN apt-get update \
    && apt-get install -y curl unzip  \
    && apt-get install -y  \
    && apt-get clean

# R environment
RUN apt-get update \
    && apt-get install -y r-base r-base-dev \
    && apt-get clean

USER jovyan
# "jovyan" stands for "Jupyter User"

# https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html
# If you want ‘~/.Renviron’ or ‘~/.Rprofile’ to be ignored by child R processes (such as those run by R CMD check and R CMD build), set the appropriate environment variable R_ENVIRON_USER or R_PROFILE_USER to (if possible, which it is not on Windows) "" or to the name of a non-existent file.
ENV R_ENVIRON_USER ""
ENV R_PROFILE_USER ""
ENV R_LIBS_USER " "

# User packages setup

# R
RUN R --slave -e "for (p in c('dplyr', 'stringr', 'readr', 'magrittr', 'ggplot2')) if (!require(p, character.only=TRUE)) install.packages(p)"


# Bash
RUN pip install bash_kernel --no-cache-dir
RUN python -m bash_kernel.install

# Markdown kernel
RUN pip install markdown-kernel --no-cache-dir
RUN python -m markdown_kernel.install 

# SoS
RUN pip install docker markdown wand graphviz imageio pillow nbformat --no-cache-dir
RUN conda install -y feather-format -c conda-forge && conda clean --all -tipsy && rm -rf /tmp/* $HOME/.cache

## trigger rerun for sos updates
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} pip install sos sos-notebook sos-r sos-python sos-bash --no-cache-dir
RUN python -m sos_notebook.install
