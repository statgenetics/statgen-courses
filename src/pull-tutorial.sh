#!/bin/bash

GIT_BRANCH="master"
TUTORIAL_NAME=${1}
USER="jovyan"

if [ -z "${TUTORIAL_NAME}" ] ; then
    echo Usage: ${0} \<turtorial name\>
    exit 1
fi

function main() {
  create_working_dir
  download_tutorial_docs
  move_data_to_user_work_dir
  prep_user
  cleanup
  exit 0
}

function create_working_dir() {
  mkdir -p /tmp/.cache
  cd /tmp/.cache
}

function download_tutorial_docs() {
  FILE_LIST=$( curl -so - https://raw.githubusercontent.com/statgenetics/statgen-courses/${GIT_BRANCH}/handout/_${TUTORIAL_NAME}.txt )
  for URL in ${FILE_LIST} ; do
    FILE=${URL##*/}
    curl -so ${FILE} ${URL}
    if [[ ${FILE} == *.ipynb ]] ; then
      jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace ${FILE}
    fi
  done
}

function move_data_to_user_work_dir() {
  mv * /home/${USER}/work
}

function prep_user() {
  if [ ! -f /home/${USER}/.firstrun ] ; then
    echo cd /home/${USER}/work >> /home/${USER}/.bashrc
    touch /home/${USER}/.firstrun
  fi
  chown -R ${USER}.users /home/${USER}
  if [ -d /home/${USER}/.work ] ; then
    echo "Copying data to local folder ..."
    mv -v /home/${USER}/.work/* /home/${USER}/work/
    rm -rf /home/${USER}/.work
  fi
}

function cleanup() {
  cd
  rm -rf /tmp/.cache
}

main
