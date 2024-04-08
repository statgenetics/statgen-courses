#! /bin/bash 

WORK_DIR=$1
DATASET_TAG=$2

echo "Making $WORK_DIR/$DATASET_TAG.fam"

zcat < $WORK_DIR/chrom1.$DATASET_TAG.dosage.gz | head -n 1 | tr ' ' "\n" | tail -n +7 | awk '{ print( $1 " " $1 " 0 0 0 -9" ) }' > $WORK_DIR/$DATASET_TAG.fam
