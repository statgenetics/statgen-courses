# For developers

This folder contains files for docker images to run the statgen course tutorials.
The `base-notebook.dockerfile` is used to build a barebone Jupyter / SoS Notebook environment for scientific computing.
Other course specific docker images will be built on top of this base image.

## Build docker images

To build the base image and push to dockerhub,

```bash
docker build --build-arg DUMMY=`date +%s` -t gaow/base-notebook -f base-notebook.dockerfile .
docker push gaow/base-notebook
```

Similiarly to build other images, eg, `vat`, and push to dockerhub,

```bash
docker build -t statisticalgenetics/vat -f vat.dockerfile .
docker push statisticalgenetics/vat
```

## Running on the cloud

First, `ssh` to the remote computer, and run the follow script to setup support environment:

```bash
bash vm-setup.sh
```
Then log out and log back in to enable the new configurations.

To setup the run for an exercise, please copy the `release` script to the remote computer, make it executable `chmod +x statgen-setup`, and type:

```
./statgen-setup launch --exercise 
```