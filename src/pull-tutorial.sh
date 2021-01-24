#!/bin/bash

GIT_BRANCH="pull-tutorials"
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
    curl -so ${URL##*/} ${URL}
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
  if [ -d /home/${USER}/.work ] ; then
    mv /home/${USER}/.work/* /home/${USER}/work/
    rm -rf /home/${USER}/.work
  fi
  chown -R ${USER}.users /home/${USER}
}

function cleanup() {
  cd
  rm -rf /tmp/.cache
}

main