sudo apt-get update && sudo apt-get install -y curl
cd /tmp
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo pip3 install sos
cd
curl -fsSL   