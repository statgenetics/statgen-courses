FROM debian:stretch-slim

MAINTAINER Gao Wang <gw2411@columbia.edu>

USER root
# Commands below will install wine 32 bit on Debian Linux then download Quanto installer

RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y wine32 curl && \
    apt-get clean
RUN curl -fsSL https://download.informer.com/win-1193149165-6cf55402-69d39bf5/quanto1_2_4.exe -o /tmp/quanto_installer.exe
RUN mkdir -p /root/.wine && mkdir -p /root/work && chmod a+rw -R /root/work
RUN echo -e '#!/bin/bash\nwine /root/.wine/drive_c/Program\ Files/Quanto/Quanto.exe' > /usr/local/bin/quanto && chmod +x /usr/local/bin/quanto
CMD ["bash"]

# Additional steps are required to complete the setup. For details, see
# https://github.com/statgenetics/statgen-courses/blob/master/docker/quanto.md
