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

To build tutorial images and push to dockerhub, eg for tutorial `igv` found under `docker` folder, please execute command below under the root of this repo (same folder as this `README.md` file) 

```bash
statgen-setup build --tutorial igv
```

Or, multiple tutorials,

```bash
statgen-setup build --tutorial igv vat pseq regression annovar
```

You can use option `--tag` to add version tag to a build, eg, `--tag 1.0.0`.

If you run into this error `denied: requested access to the resource is denied` please make sure you have push access to dockerhub account `statisticalgenetics`.
Please contact Gao Wang for the password to that account and use `docker login` command to login from your terminal. Then try build again.

### Incorporate JupyterLab setup script

It is possible to additionally customize the docker image when started from JuptyerLab environment, to download the latest version of tutorial notes and deploy *small* data in the JupyterLab server launched from the docker image.
To configure please study [this example](https://github.com/statgenetics/statgen-courses/blob/fbaed85b40ac62607b72d6933616ee69267f974e/docker/finemap.dockerfile#L12) (which is self-explanary and I'll not elaborate it here).

If your tutorial comes with a large data-set it is not suggested that a setup script is used. Instead, you can still install the `pull-tutorial.sh` script and instruct users to type a line of command `get-data` from
JupyterLab terminal when they first logged in to the server. See [this example](https://github.com/statgenetics/statgen-courses/blob/f72874d33367b12362ce234b07967a2c0fdc6185/docker/ldpred2.dockerfile#L17) for details.


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

## Setup a cloud VM

Say from a VPS service provider (eg, vultr.com) we purchase a Debian based VM droplet (Debian 9 is what I use as I document this). In the root terminal of the VM,

```bash
curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/vm-setup.sh -o /tmp/vm-setup.sh
bash /tmp/vm-setup.sh
```

## Create user accounts on cloud VM

I provide a shortcut to create new users on the cloud:

```
statgen-setup useradd --my-name student --num-users 10
```

It will generate a password for the user, add it and print the new user ID and password.

## Shutdown all running containers

For maintainance, to shutdown all containers and clean up the dangling ones,

```bash
statgen-setup clean
```

This command is only available to `root` user. For adminstrators I suggest you run `statgen-setup clean` from time to time to maintain the server. 
This will terminate running past tutorials in order to free up resources for new tutorials. 
Otherwise with too many tutorial containers running the same time on a VM it may run out of memory.

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

## How to launch course tutorials

https://github.com/statgenetics/statgen-courses/wiki/How-to-launch-course-tutorials
