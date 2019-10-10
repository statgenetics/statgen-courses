cd ~/GIT/github/misc/docker
git pull
docker build --build-arg DUMMY=`date +%s` -t gaow/base-notebook -f base-notebook.dockerfile .
docker push gaow/base-notebook
cd ~/GIT/teaching/statgen-courses
git pull
docker build --build-arg DUMMY=`date +%s` -t statisticalgenetics/vat -f docker/vat.dockerfile docker
docker push statisticalgenetics/vat
docker build --build-arg DUMMY=`date +%s` -t statisticalgenetics/pseq -f docker/pseq.dockerfile docker
docker push statisticalgenetics/pseq