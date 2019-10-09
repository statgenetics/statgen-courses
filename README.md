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

## Running on the cloud

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

## Render the HTML static website for notebooks

That is, generate https://statgenetics.github.io/statgen-courses/notebooks.html
To do this you need to have `sos` installed on your local computer if you don't already:

```bash
pip install sos -U
```

To generate the website,

```bash
./release
```

To publish the website, simply add contents in `docs/` folder to the github repository and push to github.

## Render PDF version of the tutorials

On your local computer:

```bash
cd notebooks
curl -fsSL https://raw.githubusercontent.com/gaow/pandoc-chs/master/release -o ipynb2pdf && chmod +x ipynb2pdf
curl -fsSL https://raw.githubusercontent.com/gaow/pandoc-chs/master/pm-template.latex -o pm-template.latex
docker pull gaow/debian-texlive
```

Then to convert, say `VAT.ipynb` to `VAT.pdf`

```bash
./ipynb2pdf --notebook VAT.ipynb --fontsize 11pt --titlepage False --numbersections 0
```

You also need to have `sos` installed on your local computer to run the command above.

## Converting (roughly) from MS Word to Notebook

Commands below will provide a rough conversion from Word file to Notebook file:

```bash
pandoc -s exercise.docx -t markdown -o exercise.md
notedown exercise.md > exercise.ipynb
```

However, manual polishment is still needed after the automatic conversion. This is just a start point.

# For users

## All tutorials

All tutorials can be viewed at: 

https://statgenetics.github.io/statgen-courses/notebooks.html

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
- Save on the cloud server: copy the notebook (or other files) you want to save to `work` folder found in the left panel showing the directory tree. This will be saved to the cloud server's `$HOME/<my-name>`
folder where `<my-name>` is an identification used to create the JupyterHub server (default is `hub_user`). **This is a shared folder for potentially exchange data among whoever has the link to the tutorial so if you want to store data here please create subfolders in it with your own name identifier, and save your stuff there.**.
