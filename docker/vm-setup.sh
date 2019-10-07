curl -fsSL get.docker.com -o /tmp/get-docker.sh
sh /tmp/get-docker.sh
curl -fsSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh
bash /tmp/miniconda.sh -bfp /usr/local
conda install -y -c conda-forge sos
curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/docker/statgen-setup -o statgen-setup
chmod +x statgen-setup