
#!/bin/bash

TUTORIAL_NAME=${1}

if [ -z "${TUTORIAL_NAME}" ] ; then
    echo Usage: ${0} \<turtorial name\>
    exit 1
fi



echo ${TUTORIAL_NAME}


exit

mkdir -p /tmp/.cache
cd /tmp/.cache

# Operations specific to this exercise.
wget https://raw.githubusercontent.com/statgenetics/statgen-courses/master/handout/Epistasis.pdf &&

chown -R jovyan.users * /home/jovyan
mv * /home/jovyan/work
cd
rm -rf /tmp/.cache

if [ ! -f /home/jovyan/.firstrun ] ; then
   echo cd /home/jovyan/work >> /home/jovyan/.bashrc
   touch /home/jovyan/.firstrun
fi