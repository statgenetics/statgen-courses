FROM ubuntu:focal

MAINTAINER Guangyou Li <llxxhz55555@gmail.com>

WORKDIR /tmp/
USER root
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    wget \
    curl \
    unzip \
    build-essential \
    cmake \
    gnupg2 \
    software-properties-common \
    dirmngr \
    apt-transport-https \
    ca-certificates \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libssl-dev \
    libsodium-dev \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

# For tzdata
RUN unlink /etc/localtime
RUN ln -s /usr/share/zoneinfo/America/New_York /etc/localtime

# R environment, for version cran40
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9 \
    && add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/' \
    && apt-get update \
    && apt-get install -y --no-install-recommends r-base r-base-dev r-base-core \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

RUN R --slave -e "for (p in c('abind','data.table', 'remotes', 'readr', 'dplyr', 'tibble','modelr','purrr','RSQLite')) if (!(p %in% rownames(installed.packages()))) install.packages(p, repos = 'http://cran.rstudio.com')"

# python
RUN wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh -O /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -bfp /usr/local \
    && rm -rf /tmp/miniconda.sh \
    && conda install -y python=2 \
    && conda update conda 

# MetaXcan
RUN pip install pyGWAS
RUN pip install pandas
RUN pip install scipy
#RUN pip install metaX


# PLINK
RUN wget http://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20200616.zip && \
    unzip plink_linux_x86_64_20200616.zip && mv plink /usr/local/bin &&  chmod +x /usr/local/bin/plink && rm -rf /tmp/*

# GCTA
RUN wget --no-check-certificate https://cnsgenomics.com/software/gcta/bin/gcta_1.93.2beta.zip && \
    unzip gcta_1.93.2beta.zip && mv gcta_1.93.2beta/gcta64 /usr/local/bin && rm -rf /tmp/*

# GEMMA
RUN wget https://github.com/genetics-statistics/GEMMA/releases/download/0.98.1/gemma-0.98.1-linux-static.gz && \
    zcat gemma-0.98.1-linux-static.gz > /usr/local/bin/gemma && \
    chmod +x /usr/local/bin/gemma && rm -rf /tmp/*

# FUSION
ENV P2R_VERSION d74be015e8f54d662b96c6c2a52a614746f9030d
RUN wget https://github.com/gabraham/plink2R/archive/${P2R_VERSION}.zip && \
    unzip ${P2R_VERSION}.zip && \
    R --slave -e "install.packages(c('optparse','RColorBrewer', 'RcppEigen','glmnet','HDCI'))" && \
    R --slave -e "install.packages('plink2R-${P2R_VERSION}/plink2R/',repos=NULL)" && \
    R --slave -e "remotes::install_github('stephenslab/susieR', ref='cran')" && \
    rm -rf /tmp/*

ENV FUSION_VERSION 6fedd22b47f9dab6a790c7779467f4d40ae57704

RUN curl -sSo /opt/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/pull-tutorial.sh
RUN chmod a+x /opt/pull-tutorial.sh
# Users will be asked to type in "get-data" command in bash when they run the tutorial the first time.
RUN echo "#!/bin/bash\n/opt/pull-tutorial.sh twas" > /usr/local/bin/get-data
RUN chmod a+x /usr/local/bin/get-data

RUN chmod 0777 /home
RUN useradd -s /bin/bash jovyan
USER jovyan
USER root
RUN mkdir -p /home/jovyan/
RUN chown jovyan.users -R /home/jovyan
# Download data to docker image
RUN mkdir -p /home/jovyan/.work
RUN wget -O /tmp/MR-JTI.zip "https://www.dropbox.com/sh/i9elg3m4wav4o5g/AAABdxZbVyBclbfa_1KKVftDa?dl=0" && \
    unzip MR-JTI.zip -x / -d /tmp/MR-JTI/ && \
    cp -r /tmp/MR-JTI/src/* /usr/local/bin/ &&  \
    chmod +x /usr/local/bin/MetaXcan/* && \
    cp -r /tmp/MR-JTI/data /home/jovyan/.work/ 
USER jovyan