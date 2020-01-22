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

You can use option `--tag` to add version tag to a build, eg, `--tag 1.0.0`.

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

To set it up for selected tutorial(s), for example for `vat` and `pseq` tutorials, run **as `root` user** from the terminal:

```bash
statgen-setup launch --tutorial vat pseq
```

Then run `docker ps | grep hub_user` to see a list of containers. You should get a similar output as above section. But this time instead of using address `0.0.0.0:8847` you need to type in below:

```
http://<machine URL>:<port number>
```

where `<machine URL>` is the address you used to login the cloud VM, port number is what you see above, in this case `8847`.

It is important to start the server from `root` because this will set the permission of the shared folder correctly for users of the Jupyter server to share files. These servers should be started beforehand for users to access, ideally right after running [the setup script](https://github.com/statgenetics/statgen-courses/blob/master/src/vm-setup.sh). Please see section `Run tutorials via JupyterHub server` below for instructions to users how to use the server.

**Note: if you (as a developer) would like to modify the notebook on cloud server please remember to download it to your local computer after modifications; or save to `workdir` and download from there later. The docker container does not preserve changes made to the notebook in it.** 

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

## Run tutorial from command terminal

The idea is to start your own docker container and log into it from commandline. To do this,

```
statgen-setup login --tutorial <tutorial> --my-name <my-name>
```

where `<tutorial>` is one of the available tutorials. Currently available options are:
- `igv`, `vat`, `pseq`, `annovar`, `regression`, `popgen`

`<my-name>` is any (unique) identification of your choice that should not conflict with the choice of another user if you share a computer. If you have your unique Linux user accounts, you can use `--my-name $USER`. When you are done with the tutorial just type `exit` to exit. If you log in again, your session should resume unless the container has been terminated externally.

If you want to fresh restart the container you can add `--restart` switch to the command above.

**Note: the container may be killed periodically to maintain the server at a reasonable load.** What you can do are:

- Transfer output generated during the tutorial to the cloud server: move or copy results to `~/work` folder. This will save them to the cloud server's `$HOME/<my-name>`
folder where `<my-name>` is an identification used to create the container.

Example after you log in to the container: 

```bash
cd # this will change your directory to $HOME
cp *.* ~/work # this will copy all files with any extestions from $HOME to $HOME/work. You can also replace `cp` with `mv` if you want to move the files instead of copy them over
```

- Transfer output to your computer: once they are saved to the cloud server as instructed above, you can use `scp` command from your local computer to copy the files, eg, `scp -r <username>@<cloud_IP>:./<my-name> ./` where `<my-name>` is an identification used to create the container.

## Run tutorials via JupyterHub server

To run a specific tutorial, say, `vat`, first, find out if a server already exists by typing in `docker ps | grep hub_user`. You should see something like below:

```
4888c67e9774        vat_hub_user        "tini -g -- jupyterh…"   8 seconds ago       Up 7 seconds        8888/tcp, 0.0.0.0:8847->8000/tcp   vat_hub_user
```

where `8847` is the port number you've got to keep track of. Then type in the web browser of your laptop or desktop: 

```
http://<machine URL>:<port number>
```

where `<machine URL>` is the address you used to login the cloud VM, port number is what you see above.

If you don't see the `*_hub_user` container listed above, please ask your administrator to start the tutorial server. 
(Administrators, please see section `Start tutorial server on VM` above for details.)

The server will configure itself the first time it launches; you will then be directed to a JupyterLab interface. 
Then you should see in the a notebook file `*.ipynb` on the left panel. Click on it to start running the tutorial.

**Note: the session will be there for you until it is killed explicitly, or until the server kills it periodically (currently configured to kill after 24hrs inactivity).**
**It therefore strongly encouraged that you save your work after you complete the tutorial.**
There are two ways to do this: 
- Save to your computer (recommended): to do this, simply right click on the notebook to bring up the dropdown menu, and click `Download` to download the notebook to your computer to save your own copy.
- Save on the cloud server: copy the notebook (or other files) you want to save to `work` folder found in the left panel showing the directory tree. **This is a shared folder for potentially exchange data among whoever has the link to the tutorial so if you want to store data here please create subfolders in it with your own name identifier, and save your stuff there**. e.g., `work/<your first name>-<your last name>`. Please ask the course teaching assistant if you are not sure how to create this folder.

Under the hood, `work` folder is mounted to the cloud server's `/root/<my-name>` folder where `<my-name>` is an identification used when the administrator created the JupyterHub server (default is `hub_user`). As a regular user you will not have direct access to `/root` folder but it won't matter because everything is accessible from the `work` folder of your Jupyter IDE.

## Convert & Save tutorials to MS Word format

We have the server configured to make it possible to export a notebook as `docx` file (MS Word format) 
to your local computer. To do this, simply click on `File` botton in the menu bar at the top left of the
notebook interface, then `Export Notebook As -> Export Notebook to Docx`. Notice that PDF format export is
currently not supported in our setup (requires `xelatex` which we don't install in our server).
