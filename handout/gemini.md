# Prepare gemini input data with VEP annotation

Required software are `vt` and `vep` and are installed to docker image via `gemini.dockerfile`. We have locked the version for both `vt` and `vep` out of consideration for future reproducibility

## VCF decompose with `vt`

FIXEM: Diana please add in `vt` workflow.

## Annotate with VEP

Largely following from [this page](https://gemini.readthedocs.io/en/latest/content/functional_annotation.html#stepwise-installation-and-usage-of-vep).

### Download reference data

**Here I assume our data is GRCh37**. And we use VEP version 87 consistent with our VEP software.

```
mkdir -p ~/.vep && cd ~/.vep
wget ftp://ftp.ensembl.org/pub/release-87/variation/VEP/homo_sapiens_vep_87_GRCh37.tar.gz && \
tar zxvf homo_sapiens_vep_87_GRCh37.tar.gz
```

It is about 5GB data.

### Annotate

Input is `AD.decomposed.vcf` output is `AD.decomposed.vep.vcf`

```bash
data=AD.decomposed
```

```bash
variant_effect_predictor.pl -i $data.vcf \
    --cache \
    --sift b \
    --polyphen b \
    --symbol \
    --numbers \
    --biotype \
    --total_length \
    -o $data.vep.vcf \
    --vcf \
    --fields Consequence,Codons,Amino_acids,Gene,SYMBOL,Feature,EXON,PolyPhen,SIFT,Protein_position,BIOTYPE \
    --port 3337 \
    --force_overwrite
￼```

Added `--port 3337` for GRCh37.

### Build gemini database

```bash
gemini load -v $data.vep.vcf -t VEP $data.db
```

**caution** : I found a warning message: 

```
[W::vcf_parse] INFO 'EVSMAF' is not defined in the header, assuming Type=String
```

If we don't fix this, then annotation filters base on MAF will fail!
So I ended up **manually editing all input VCF files adding this line to the header**:

```
##INFO=<ID=EVSMAF,Number=1,Type=Float,Description="EVS Minor allele frequency">
```

then run all the commands above again ...