# setup web server
apt-get update & apt-get install -y nginx acl
# setup docker
curl -fsSL get.docker.com -o /tmp/get-docker.sh
sh /tmp/get-docker.sh
# setup SoS to run utility scripts
curl -fsSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh
bash /tmp/miniconda.sh -bfp /usr/local
conda install -y -c conda-forge sos
# utility script for running tutorials
curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/statgen-setup -o /usr/local/bin/statgen-setup
chmod +x /usr/local/bin/statgen-setup
# utility script to export notebook to PDF
curl -fsSL https://raw.githubusercontent.com/gaow/pandoc-chs/master/release -o /usr/local/bin/ipynb2pdf
chmod +x /usr/local/bin/ipynb2pdf
curl -fsSL https://raw.githubusercontent.com/gaow/pandoc-chs/master/pm-template.latex -o $HOME/pm-template.latex
docker pull gaow/debian-texlive