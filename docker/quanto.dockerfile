FROM debian:stretch-slim

MAINTAINER Gao Wang <wang.gao@columbia.edu>

USER root
# Commands below will install wine 32 bit on Debian Linux then download Quanto installer

RUN apt-get update && apt-get install -y gnupg
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ=America/New_York apt-get install -y wine32 curl && \
    apt-get clean
RUN curl -fsSL https://download.informer.com/win-1193149165-9c906e02-6c04fde6-948588d190304e9217-b9184ace9acd0ff52-850714036-1192113413/quanto1_2_4.exe -o /tmp/quanto_installer.exe
RUN mkdir -p /root/.wine && mkdir -p /root/work && chmod a+rw -R /root/work
RUN echo -e '#!/bin/bash\nwine /root/.wine/drive_c/Program\ Files/Quanto/Quanto.exe' > /usr/local/bin/quanto && chmod +x /usr/local/bin/quanto
CMD ["bash"]

# Additional steps are required to complete the setup. For details, see
# https://github.com/statgenetics/statgen-courses/blob/master/docker/quanto.md
