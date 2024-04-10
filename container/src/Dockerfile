FROM ghcr.io/prefix-dev/pixi:latest
USER root
# For security reasons, SSL certificates and timezone database must be installed by host package manager
RUN apt-get update
RUN apt-get -y install ca-certificates tzdata curl

# Copy over configs and environments
COPY r_libs.yml /tmp
COPY python_libs.yml /tmp
COPY global_packages /tmp
COPY fixes.sh /tmp

RUN mkdir -p /root/.config/pixi && \
    echo 'default_channels = ["dnachun", "conda-forge", "bioconda"]' > /root/.config/pixi/config.toml

# Use bash as default shell instead of dash
RUN ln -sf /bin/bash /bin/sh  

# Install global packages with pixi
RUN pixi global install $(tr '\n' ' ' < /tmp/global_packages)
ENV PATH="/root/.pixi/bin:${PATH}"

# Install R and Python libraries with micromamba (will replace with pixi in future)
RUN micromamba config prepend channels nodefaults 
RUN micromamba config prepend channels bioconda
RUN micromamba config prepend channels conda-forge
RUN micromamba config prepend channels dnachun
RUN micromamba shell init --shell=bash /root/micromamba
RUN micromamba env create --yes --quiet --file /tmp/r_libs.yml;
RUN micromamba env create --yes --quiet --file /tmp/python_libs.yml;
RUN micromamba clean --all --yes

# Register Juypter kernels
RUN find /root/micromamba/envs/python_libs/share/jupyter/kernels/ -maxdepth 1 -mindepth 1 -type d | \
    xargs -I % jupyter-kernelspec install %
RUN find /root/micromamba/envs/r_libs/share/jupyter/kernels/ -maxdepth 1 -mindepth 1 -type d | \
    xargs -I % jupyter-kernelspec install %

# Set path for R and Python libraries
RUN bash /tmp/fixes.sh # Run custom fixes
CMD ["jupyter-lab", "--config", "/root/.jupyter/jupyter_notebook_config.py"]
