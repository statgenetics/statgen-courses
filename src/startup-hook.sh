#!/bin/bash

GIT_BRANCH="master"
TUTORIAL_NAME=${1}

if [ -z "${TUTORIAL_NAME}" ] ; then
    echo Usage: ${0} \<turtorial name\>
    exit 1
fi

function main() {
  curl -sSo /usr/local/bin/pull-tutorial.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/${GIT_BRANCH}/src/pull-tutorial.sh
  chmod a+x /usr/local/bin/pull-tutorial.sh
  # Add notebook startup hook
  # https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#startup-hooks
  mkdir -p /usr/local/bin/start-notebook.d
  # For large files, you can put README as a placeholder instead of the actual tutorial name, to skip pre-loading any files to it	
  echo -e '#!/bin/bash\n/usr/local/bin/pull-tutorial.sh ${TUTORIAL_NAME}' > /usr/local/bin/start-notebook.d/get-updates.sh
  chmod a+x /usr/local/bin/start-notebook.d/get-updates.sh
  # Users can type in "get-data" command in bash when they run the tutorial the first time, to download the data.
  cp /usr/local/bin/start-notebook.d/get-updates.sh /usr/local/bin/get-data
}

main