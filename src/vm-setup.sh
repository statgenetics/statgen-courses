set -e
# setup web server
apt-get update && apt-get install -y nginx acl
# setup docker
curl -fsSL get.docker.com -o /tmp/get-docker.sh && sh /tmp/get-docker.sh
# setup SoS to run utility scripts
curl -fsSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh && bash /tmp/miniconda.sh -bfp /usr/local
conda install -y -c conda-forge sos
# utility script for running tutorials
curl -fsSL https://raw.githubusercontent.com/statgenetics/statgen-courses/master/src/statgen-setup -o /usr/local/bin/statgen-setup && chmod +x /usr/local/bin/statgen-setup
# pull docker images
statgen-setup update --tutorial vat pseq igv popgen regression annovar mlink slink gemini
# add users
statgen-setup useradd --my-name student --num-users 12 2> useradd.log
# setup gemini data
# This will download large data-set; please comment it out if you do not need it
statgen-setup gemini-data --gemini-data-dir /root/gemini-data && chown root.users -R /root/gemini-data