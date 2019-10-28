# For developers

- `docker` folder contains files for docker images to run the statgen course tutorials.
- `notebook` folder contains all tutorial notebooks.
- `src` folder contains utility scripts eg, tools to setup the Jupyter server online.

## Build tutorial specific images

[`gaow/base-notebook`](https://cloud.docker.com/u/gaow/repository/docker/gaow/base-notebook), 
a minimal JupyterHub / SoS Notebook environment for scientific computing, is used to derive
tutorial specific images in this folder.

To build tutorial images and push to dockerhub, eg for `vat` tutorial,

```bash
docker build --build-arg DUMMY=`date +%s` -t statisticalgenetics/vat -f docker/vat.dockerfile docker 
docker push statisticalgenetics/vat
```

## Setup course JupyterHub server on your computer

Now you should be able to use the images on your computer, as long as you have [both `SoS` and `docker` installed](http://statgen.us/lab-wiki/orientation/jupyter-setup.html).
Additionally you have to put `src/statgen-setup` script to your `PATH` and change it to executable, eg, `chmod +x ~/bin/statgen-setup` if you put it under `~/bin` which is
part of your `PATH`.

To set it up for selected tutorial(s), for example for `vat` and `pseq` tutorials,

```bash
statgen-setup launch --tutorials vat pseq
```

After all steps are complete, you check the Jupyter Hub server on your machine:

```
$ docker ps

CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                              NAMES
4888c67e9774        vat_hub_user        "tini -g -- jupyterh…"   8 seconds ago       Up 7 seconds        8888/tcp, 0.0.0.0:8847->8000/tcp   vat_hub_user
```

The `0.0.0.0:8847` is the address to the server (your port number may vary). To view it, simply paste that address to your browser. 

## Setup course JupyterHub server on cloud

Having tested the course image and server work on a local computer it is time to deploy them to a cloud service for others to use.

Say from a VPS service provider (eg, vultr.com) we purchase a Debian based VM droplet (Debian 9 is what I use as I document this). In the root terminal of the VM,

```bash
curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/vm-setup.sh -o /tmp/vm-setup.sh
bash /tmp/vm-setup.sh
```
To set it up for selected tutorial(s), for example for `vat` and `pseq` tutorials,

```bash
statgen-setup launch --tutorials vat pseq
```

For maintainance, to shutdown all containers and clean up the dangling ones,

```bash
statgen-setup clean
```

**Note: if you (as a developer) would like to modify the notebook on cloud server please remember to download it to your local computer after modifications; or save to `workdir` and download from there later. The docker container does not preserve changes made to the notebook in it.** 

## Render HTML static website for notebooks

That is, generate https://statgenetics.github.io/statgen-courses/notebooks.html.
To do this you need to have `sos` installed on your local computer if you don't already:

```bash
pip install sos -U
```

To generate the website,

```bash
./release
```

To publish the website, simply add contents in `docs/` folder to the github repository and push to github.

## Convert (roughly) from MS Word to Notebook

Commands below will provide a rough conversion from `docx` file (`doc` files will not work!) to Notebook file:

```bash
pandoc -s exercise.docx -t markdown -o exercise.md
notedown exercise.md > exercise.ipynb
```

The notedown program can be installed via `pip install notedown`. Additionally you need to install `pandoc` program.

The conversion is just a start point. Manual polishment is still needed after the automatic conversion.
Specifically, it will be important to separate codes from text to different Notebook cells,
and assign to each cell the approperate kernel if using SoS multi-language Notebook. Command output should also be
removed from the text because they will be generated automatically and formatted better, after executing the notebook.

# For users

## All tutorials

All tutorials can be viewed at: 

https://statgenetics.github.io/statgen-courses/notebooks.html

## Run tutorial from command terminal

The idea is to start your own docker container and log into it from commandline. To do this,

```
statgen-setup login --tutorials vat --my-name <my-name>
```

where `<my-name>` is an identification that you chose (that should not conflict with the choice of another user if you share a computer). When you are done with the tutorial just type `exit` to exit.

## Run tutorials via JupyterHub server

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
- Save on the cloud server: copy the notebook (or other files) you want to save to `work` folder found in the left panel showing the directory tree. This will be saved to the cloud server's `$HOME/<my-name>`
folder where `<my-name>` is an identification used to create the JupyterHub server (default is `hub_user`). **This is a shared folder for potentially exchange data among whoever has the link to the tutorial so if you want to store data here please create subfolders in it with your own name identifier, and save your stuff there**.

## Convert & Save tutorials to MS Word format

We have the server configured to make it possible to export a notebook as `docx` file (MS Word format) 
to your local computer. To do this, simply click on `File` botton in the menu bar at the top left of the
notebook interface, then `Export Notebook As -> Export Notebook to Docx`. Notice that PDF format export is
currently not supported in our setup (requires `xelatex` which we don't install in our server).