# For developers

- `docker` folder contains files for docker images to run the statgen course tutorials.
The `base-notebook.dockerfile` is used to build a barebone Jupyter / SoS Notebook environment for scientific computing.
Other course specific docker images will be built on top of this base image.
- `notebook` folder contains all tutorial notebooks.
- `src` folder contains utility scripts eg, tools to setup the Jupyter server online.

## Build docker images

To build the base image and push to dockerhub, on your local computer where `docker` is installed,

```bash
docker build --build-arg DUMMY=`date +%s` -t gaow/base-notebook -f docker/base-notebook.dockerfile docker
docker push gaow/base-notebook
```

Similiarly to build other images, eg, `vat`, and push to dockerhub,

```bash
docker build --build-arg DUMMY=`date +%s` -t statisticalgenetics/vat -f docker/vat.dockerfile docker 
docker push statisticalgenetics/vat
```

## Running on the cloud

First, `ssh` to the remote computer assuming `root` access (for a newly purchased VM for example), and run the follow script to setup support environment:

```bash
bash vm-setup.sh
```

You will find `vm-setup.sh` script in `src` folder of this repo.

To set it up for selected tutorial, for example for `vat` and `pseq` tutorials,

```bash
statgen-setup launch --tutorials vat pseq
```

## Render the HTML static website for notebooks

You need to have `sos` installed if you don't already:

```bash
pip install sos -U
```

To generate the website,

```bash
./release
```

# For users

## Run tutorials

To view a specific tutorial, say, `vat`, you can simply type in your browser:

```
http://<ip-address>/vat.html
```

The server will configure itself the first time it launches; you will then be directed to a JupyterLab interface. 
Then you should see in the a notebook file `*.ipynb` on the left panel. Click on it to start running the tutorial.

**Note: the session will be there for you until it is killed explicitly, or until the server kills it periodically (currently configured to kill after 24hrs inactivity).**
**It therefore strongly encouraged that you save your work after you complete the tutorial.**
There are two ways to do this: 
- Save to your computer (recommended): to do this, simply right click on the notebook to bring up the dropdown menu, and click `Download` to download the notebook to your computer to save your own copy.
- Save on the cloud server: copy the notebook (or other files) you want to save to `work` folder found in the left panel showing the directory tree. 

## Convert tutorials to HTML and PDF format to download

All notebooks can be viewed at: 

https://statgenetics.github.io/statgen-courses/notebooks.html