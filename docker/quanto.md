# `quanto` docker image

`quanto` is a Windows (32bit!) based program with GUI. Docker images for cross platform use are Linux based. However for simple Windows programs it is possible to run them under Linux using an emulator program `wine`. So the idea is to run quanto under Linux based container via the emulator, then run the docker image under any other OS with proper GUI sharing settings.

## Build docker image for `quanto` installer

See `quanto.dockerfile`. Make a docker image from that file.

## Install `quanto` to a docker container and push the change back to the image

To do this we first start a container from the image then log into the container and make change. On a Linux host,

```bash
docker run -d --rm --security-opt label:disable -t --name quanto-installer --net=host --env="DISPLAY" -v "$HOME/.Xauthority:/root/.Xauthority:rw" -v $HOME/quanto:/root/work statisticalgenetics/quanto bash
```
Then log into it,

```
docker exec -it quanto-installer bash
```
and run:
```
wine /tmp/quanto_installer.exe
```
and follow instructions. By default program will be installed to `/root/.wine/drive_c/Program Files/Quanto/Quanto.exe`

Then run

```
sed  -i "1s/-e //" /usr/local/bin/quanto
```
to fix a syntax error in the script, then exit the docker container,
```
exit
```

Now we need to push the changes in the container back to the image. Check out the status of the container:
```
docker ps
```
```
# CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
# d1f9d78678b9        statisticalgenetics/quanto          "bash"              10 minutes ago      Up 10 minutes                           quanto-installer
```
and commit the changes
```
docker commit quanto-installer statisticalgenetics/quanto
docker push statisticalgenetics/quanto
```

Now we can stop that container as it was only intended to install quanto:
```
docker stop quanto-installer
```

Notice that I can also, in principle, tarball the installed `quanto` and save it somewhere else. Next time I make an image I can directly grab and use it. But this is likely a violation of copyright so I'll not do that.

## Run `quanto`

The trickiness is to run GUI based application in Docker. It is different for different OS.

### On Linux

```
docker run --rm --security-opt label:disable -t --net=host --env="DISPLAY" -v "$HOME/.Xauthority:/root/.Xauthority:rw" -v $HOME/quanto:/root/work statisticalgenetics/quanto quanto
```

### On Mac
FIXME

### On Windows
FIXME
