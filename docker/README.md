# For developers

This folder contains files for docker images to run the statgen course tutorials.
The `base-notebook.dockerfile` is used to build a barebone Jupyter / SoS Notebook environment for scientific computing.
Other course specific docker images will be built on top of this base image.

## Build docker images

To build the base image and push to dockerhub, on your local computer where `docker` is installed,

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

First, `ssh` to the remote computer assuming `root` access (for a newly purchased VM for example), and run the follow script to setup support environment:

```bash
bash vm-setup.sh
```

You will find `vm-setup.sh` script in `src` folder of this repo.

To set it up for selected tutorial, for example for `vat` and `pseq` tutorials,

```
statgen-setup launch --tutorials vat pseq 
```