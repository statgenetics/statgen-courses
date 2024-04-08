#! /bin/bash

for chrom in `seq 1 22`; 
do 
    echo "chr$chrom"
    env SGE_TASK_ID=$chrom $*
done
