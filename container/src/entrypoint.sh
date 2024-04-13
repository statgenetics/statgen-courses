#!/bin/bash

curl -o /tmp/jn_entrypoint.sh https://raw.githubusercontent.com/yiweizh-memverge/statgen-courses/master/setup/MMCloud/jn_entrypoint.sh
chmod +x /tmp/jn_entrypoint.sh
bash /tmp/jn_entrypoint.sh

cd /root/statgen-courses/
jupyter-lab
