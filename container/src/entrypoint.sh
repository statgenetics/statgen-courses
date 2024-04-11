#!/bin/bash

curl -o /root/jn_entrypoint.sh https://raw.githubusercontent.com/statgenetics/statgen-courses/master/setup/MMCloud/jn_entrypoint.sh
chmod +x /root/jn_entrypoint.sh
bash /root/jn_entrypoint.sh

cd /root/statgen-courses/
jupyter-lab --config /root/.jupyter/jupyter_notebook_config.py