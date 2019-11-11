# For developers

- `docker` folder contains files for docker images to run the statgen course tutorials.
- `notebooks` folder contains tutorial notebooks.
- `handout` folder contains some handouts.
- `src` folder contains utility scripts eg, tools to setup the Jupyter server online.

## Prepare your computer to manage the tutorials

Software you need to install on your computer are `SoS` (simply type `pip install sos` to install, or, check out [here for alternative installation methods](https://vatlab.github.io/sos-docs/running.html) if you have troubles with that command) and [`docker`](http://statgen.us/lab-wiki/orientation/jupyter-setup.html#install-docker).
Additionally to run the course material on your computer (not on cloud VM) you have to put `src/statgen-setup` script to your `PATH` and change it to executable, 
eg, `chmod +x ~/bin/statgen-setup` if you put it under `~/bin` which is part of your `PATH`. To verify your setup, type:

```
statgen-setup -h
```

you should see some meaningful output.

## Build tutorial specific images

[`gaow/base-notebook`](https://cloud.docker.com/u/gaow/repository/docker/gaow/base-notebook), 
a minimal JupyterHub / SoS Notebook environment for scientific computing, is used to derive
tutorial specific images in this folder.

To build tutorial images and push to dockerhub, eg for tutorial `igv` found under `docker` folder,

```bash
statgen-setup build --tutorial igv
```

Or, multiple tutorials,

```bash
statgen-setup build --tutorial igv vat pseq regression annovar
```

If you run into this error `denied: requested access to the resource is denied` please make sure you have push access to dockerhub account `statisticalgenetics`.
Please contact Gao Wang for the password to that account and use `docker login` command to login from your terminal. Then try build again.

## Setup course JupyterHub server on your computer

To set it up for selected tutorial(s) on your local computer, for example for `vat` and `pseq` tutorials,

```bash
statgen-setup launch --tutorial vat pseq
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

### Setup a cloud VM

Say from a VPS service provider (eg, vultr.com) we purchase a Debian based VM droplet (Debian 9 is what I use as I document this). In the root terminal of the VM,

```bash
curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/vm-setup.sh -o /tmp/vm-setup.sh
bash /tmp/vm-setup.sh
```

### Start tutorial server on VM

To set it up for selected tutorial(s), for example for `vat` and `pseq` tutorials, run from the root terminal

```bash
statgen-setup launch --tutorial vat pseq
```

For maintainance, to shutdown all containers and clean up the dangling ones,

```bash
statgen-setup clean
```

I suggest you run `statgen-setup clean` before launching a new tutorial (`statgen-setup launch`). This will terminate other running tutorial servers on machine to free up resources for the new tutorial. Otherwise you might run out of memory for having too many tutorials servers running the same time on a small VM.

**Note: if you (as a developer) would like to modify the notebook on cloud server please remember to download it to your local computer after modifications; or save to `workdir` and download from there later. The docker container does not preserve changes made to the notebook in it.** 

## Create user accounts on cloud VM

I provide a shortcut to create new users on the cloud:

```
statgen-setup useradd --my-name student --num-users 10
```

It will generate a password for the user, add it and print the new user ID and password.

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

## Tutorial notebooks

Some tutorials are available as IPython Notebooks and can be viewed at: 

https://statgenetics.github.io/statgen-courses/notebooks.html

## Available tutorials

Available tutorials (via `--tutorial` option of `statgen-setup` script) are those with
[docker images prepared](https://hub.docker.com/u/statisticalgenetics/). 

## Run tutorial from command terminal

The idea is to start your own docker container and log into it from commandline. To do this,

```
statgen-setup login --tutorial <tutorial> --my-name <my-name>
```

where `<tutorial>` is one of the available tutorials. Currently available options are:
- `igv`, `vat`, `pseq`, `annovar`, `regression`, `popgen`

`<my-name>` is any (unique) identification of your choice that should not conflict with the choice of another user if you share a computer. If you have your unique Linux user accounts, you can use `--my-name $USER`. When you are done with the tutorial just type `exit` to exit.

## Run tutorials via JupyterHub server

To run a specific tutorial, say, `vat`, you can simply type in your browser:

```
http://<ip-address>/vat.html
```

(If you are not provided this link, you would need to login as root to the cloud VM you are assigned to, and start the tutorial server before you can run them. See section `Start tutorial server on VM` above for details.)

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
