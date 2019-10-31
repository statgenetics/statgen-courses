FROM debian:stretch-slim

MAINTAINER Gao Wang <gw2411@columbia.edu>

USER root
WORKDIR /root

# Commands below will install wine 32 bit on Debian Linux then download Quanto installer
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y wine32 curl && \
    apt-get clean
RUN curl -fsSL https://download.informer.com/win-1193149165-6cf55402-69d39bf5/quanto1_2_4.exe -o /tmp/quanto_installer.exe
RUN mkdir -p /root/.wine && mkdir -p /root/work && chmod a+rw -R /root/work
CMD ["bash"]

# But this is not over ... because the downloaded program is an installer, we have to actually log into that installer, install it then push the change back to the image. 
# To configure it on a Linux host, what worked for me was,
# $ docker run -d --rm --security-opt label:disable -t --name quanto --net=host --env="DISPLAY" -v "$HOME/.Xauthority:/root/.Xauthority:rw" -v $HOME/quanto:/root/work quanto-app bash
# Then I log into it,
# $ docker exec -it quanto bash
# and run:
# $ wine /tmp/quanto_installer.exe
# and follow instructions. By default program will be installed to `/root/.wine/drive_c/Program Files/Quanto/Quanto.exe`
# Then exit the docker container.
# $ exit
# After it is installed, I need to push the changes back to the image. Now on the host,
# $ docker ps
# CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
# d1f9d78678b9        quanto-app          "bash"              10 minutes ago      Up 10 minutes                           quanto
# $ docker commit quanto quanto-app
# sha256:3e7bf60d0569adafa4042c4dbf66c99cf63c5997abbf973145e9f64f354ffa47
# Now I can stop that container as it was intended to install quanto this time.
# $ docker stop quanto
# Next time to run it, 
# $ docker run --rm --security-opt label:disable -t --net=host --env="DISPLAY" -v "$HOME/.Xauthority:/root/.Xauthority:rw" -v $HOME/quanto:/root/work quanto-app wine /root/.wine/drive_c/Program Files/Quanto/Quanto.exe
# I can also, in principle, tarball the installed `/root/Quanto` folder, save it somewhere else and directly grab and use it when I build this docker image. But this is likely a violation of copyright so I'll not do that.
