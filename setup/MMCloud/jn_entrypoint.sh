#!/bin/bash

repo_dir=statgen-courses
BUCKET_ACCESS_KEY=${BUCKET_ACCESS_KEY:-""}
BUCKET_SECRET_KEY=${BUCKET_SECRET_KEY:-""}


cd /root/

# Clone GitHub repo
git clone https://github.com/statgenetics/statgen-courses.git

# Download external resources
mkdir -p $repo_dir/handout/ldpred2
curl -o "$repo_dir/handout/ldpred2/ldpred.ipynb" https://raw.githubusercontent.com/cumc/bioworkflows/master/ldpred/ldpred.ipynb
curl -o "$repo_dir/handout/ldpred2/ldpred2_example.ipynb" https://raw.githubusercontent.com/cumc/bioworkflows/master/ldpred/ldpred2_example.ipynb


# Sync the handout directory
AWS_ACCESS_KEY_ID=$BUCKET_ACCESS_KEY AWS_SECRET_ACCESS_KEY=$BUCKET_SECRET_KEY aws s3 sync s3://opcenter-bucket-ada686a0-ccdb-11ee-b922-02ebafc2e5cf/statgen_course /root/statgen-courses/handout

