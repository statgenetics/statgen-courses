FROM jupyter/base-notebook:hub-1.0.0

MAINTAINER Gao Wang <gw2411@columbia.edu>

USER root
# Tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    apt-transport-https \
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
    && apt-get install -y --no-install-recommends graphviz pandoc software-properties-common nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

# R environment, for version 3.5
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/' \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
    && apt-get update \
    && apt-get install -y r-base r-base-dev r-base-core \
    && apt-get clean

RUN R --slave -e "for (p in c('dplyr', 'stringr', 'readr', 'magrittr', 'ggplot2')) if (!require(p, character.only=TRUE)) install.packages(p, repos = 'http://cran.rstudio.com')"

USER jovyan
# "jovyan" stands for "Jupyter User"

# https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html
# If you want ‘~/.Renviron’ or ‘~/.Rprofile’ to be ignored by child R processes (such as those run by R CMD check and R CMD build), set the appropriate environment variable R_ENVIRON_USER or R_PROFILE_USER to (if possible, which it is not on Windows) "" or to the name of a non-existent file.
ENV R_ENVIRON_USER ""
ENV R_PROFILE_USER ""
ENV R_LIBS_USER " "

# Bash
RUN pip install bash_kernel --no-cache-dir
RUN python -m bash_kernel.install

# Markdown kernel
RUN pip install markdown-kernel --no-cache-dir
RUN python -m markdown_kernel.install 

# Some setup for Jupyterhub
RUN pip install --no-cache dockerspawner jupyterhub-tmpauthenticator

# SoS Suite
RUN pip install docker markdown wand graphviz imageio pillow nbformat jupyterlab feather-format --no-cache-dir

## trigger rerun for sos updates
ARG DUMMY=unknown
RUN DUMMY=${DUMMY} pip install sos sos-notebook sos-r sos-python sos-bash --no-cache-dir
RUN python -m sos_notebook.install
RUN jupyter labextension install transient-display-data
RUN jupyter labextension install jupyterlab-sos
