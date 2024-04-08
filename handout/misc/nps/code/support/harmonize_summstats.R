ASSERT <- function(test) {
    if (length(test) == 0) {
        stop(paste("ASSERT fail for empty conditional:",
                   deparse(substitute(test))))
    }

    if (is.na(test)) {
        stop(paste("ASSERT fail for missing value:",
                   deparse(substitute(test))))
    }
    
    if (!test) {
        stop(paste("ASSERT fail:", deparse(substitute(test))))
    }
}

args <- commandArgs(trailingOnly=TRUE)

if (length(args) != 3) {
    cat("Usage: Rscript harmonize_summstats.R <summary stats file> <work dir> <cohort name>\n")
    stop("")
}

summstatfile <- args[1]
workdir <- args[2]
cohortname <- args[3]

cat("Reading summary statistics from:", summstatfile, "...")

summstats <- read.delim(summstatfile, 
               header=TRUE, sep="\t", stringsAsFactors=FALSE)

# Minimal format
# col 1: chromosome numbers, "1", "2", ...
# col 2: position
# col 3: a1
# col 4: a2
# col 5: effal (effect allele) 
# col 6: pval (p-value of association)
# col 7: effbeta (beta of effect allele)
# col 8 (OPTIONAL): effaf (effect allele frequency)

if (ncol(summstats) != 7 && ncol(summstats) != 8) {
    cat("\n")
    cat("Expect tab-delimited text file with the following header\n")
    cat(paste(c("chr", "pos", "a1", "a2", "effal", "pval", "effbeta",
                "effaf"), collapse="\t"), "\n")
    stop("")
}

# effaf is optional
if (ncol(summstats) == 7) {
    if (any(colnames(summstats) !=
            c("chr", "pos", "a1", "a2", "effal", "pval", "effbeta"))) {

        cat("\n")
        cat("Expect tab-delimited text file with the following header\n")
        cat(paste(c("chr", "pos", "a1", "a2", "effal", "pval", "effbeta"), 
                  collapse="\t"), "\n")

        stop("")
    }
}

# with effaf
if (ncol(summstats) == 8) {
    if (any(colnames(summstats) !=
            c("chr", "pos", "a1", "a2", "effal", "pval", "effbeta",
              "effaf"))) {

        cat("\n")
        cat("Expect tab-delimited text file with the following header\n")
        cat(paste(c("chr", "pos", "a1", "a2", "effal", "pval", "effbeta",
                    "effaf"), collapse="\t"), "\n")
        stop("")
    }
}

if (nrow(summstats) == 0) {
    cat("\n")
    stop(summstatfile, ": empty")
}

if (any(is.na(summstats$chr))) {
    cat("\n")
    stop(summstatfile, ": NA in chr")
}

if (any(is.na(summstats$pos))) {
    cat("\n")
    stop(summstatfile, ": NA in pos")
}

if (any(is.na(summstats$a1) | is.na(summstats$a2) | is.na(summstats$effal))) {
    cat("\n")
    stop(summstatfile, ": NA in a1, a2 or effal")
}

if (any(is.na(summstats$pval) | is.na(summstats$effbeta) |
        is.nan(summstats$pval) | is.nan(summstats$effbeta))) {
    cat("\n")
    stop(summstatfile, ": NA or NaN in pval or effbeta")
}

if (any(summstats$pval == 0)) {
    cat("\n")
    print(sumstats[sumstats$pval == 0, ])
    stop(summstatfile, ": numerical underflow (p-value == 0)")
}

if (("effaf" %in% colnames(summstats)) && any(is.na(summstats$effaf))) {
    cat("\n")
    stop(summstatfile, ": NA in effaf")
}
    

summstat.chr <- as.character(unique(summstats$chr))

if (length(setdiff(summstat.chr, as.character(1:22))) != 0) {
    stop(summstatfile, ": chr column allows only 1, 2, ..., 22:",
         paste(setdiff(summstat.chr, as.character(1:22)), collapse=", "))

}

if (!all((summstats$effal == summstats$a1) |
         (summstats$effal == summstats$a2))) {

    stop(summstatfile, ": effal should match a1 or a2 allele")
}

cat("OK\n")
cat(nrow(summstats), "variants read\n")

summstats <- cbind(summstats,
                   chr.pos=paste(summstats$chr, summstats$pos, sep=":"),
                   stringsAsFactors=FALSE)

# no Indels
summstats <- summstats[nchar(summstats$a1) == 1 &
                       nchar(summstats$a2) == 1, ]

cat("Excluding indels:", nrow(summstats), "variants remaining\n")

summstats <- cbind(summstats,
                   a1a2=paste(summstats$chr, ":", summstats$pos, "_",
                              summstats$a1, "_", summstats$a2, sep=''),
                   a2a1=paste(summstats$chr, ":", summstats$pos, "_",
                              summstats$a2, "_", summstats$a1, sep=''),
                   stringsAsFactors=FALSE)

if (any(duplicated(summstats$a1a2))) {
    
    dup.a1a2 <- unique(summstats$a1a2[duplicated(summstats$a1a2)])
    cat("WARNING: duplicated markers in summary statistics file",
        summstatfile, ":\n")    
    print(summstats[summstats$a1a2 %in% dup.a1a2, ])
    
    summstats <- summstats[!(summstats$a1a2 %in% dup.a1a2), ]
    cat("Excluding duplicates:", nrow(summstats), "variants remaining\n")

    ASSERT(all(!duplicated(summstats$a1a2)))
}

######
# UKBB
tab <- NULL

cat("Reading UK Biobank marker information:\n")

ukbb.rejected.snpIDs <- c()

for (chr in 1:22) {
    cat("chrom", chr, "\n")
    
    fname <- paste(workdir, "/", "chrom", chr, ".ukb_mfi.txt", sep='')

    if (!file.exists(fname)) {
        cat("Missing", fname,
            ": use ukbb_support/filter_snps_by_summstats.job\n")
        stop("")
    }

    tab.chr <- 
        read.delim(fname, header=FALSE, stringsAsFactors=FALSE, sep="\t")

    ASSERT(ncol(tab.chr) == 8)
    
    colnames(tab.chr) <- 
        c("snpID", "rsID", "BP", "REF", "ALT", "MAF", "MINOR", "INFO")

    ASSERT(all(!is.na(tab.chr$MAF)))

    # some INFO are NA
#    ASSERT(all(!is.na(tab.chr$INFO)))

    
    # Get AAF (alternative AF)
    AAF.chr <- rep(NA, nrow(tab.chr))
    AAF.chr[tab.chr$ALT == tab.chr$MINOR] <- tab.chr$MAF[tab.chr$ALT == tab.chr$MINOR]
    AAF.chr[tab.chr$REF == tab.chr$MINOR] <- 1 - tab.chr$MAF[tab.chr$REF == tab.chr$MINOR]
    
    # MAF >= 5% & INFO >= 0.4
    if (any((tab.chr$MAF < 0.05) |
            is.na(tab.chr$INFO) | (tab.chr$INFO < 0.4))) {
        cat("    Removing", sum(tab.chr$MAF < 0.05), " with MAF < 0.05\n")
        cat("    Removing", sum(is.na(tab.chr$INFO) | (tab.chr$INFO < 0.4)),
            " with INFO < 0.4\n")
        
        ukbb.rejected.snpIDs <-
            c(ukbb.rejected.snpIDs, 
              tab.chr$snpID[(tab.chr$MAF < 0.05) |
                            is.na(tab.chr$INFO) | (tab.chr$INFO < 0.4)])
    }

    # Indels
    if (any((nchar(tab.chr$REF) != 1) | (nchar(tab.chr$ALT) != 1))) {
        cat("    Removing",
            sum((nchar(tab.chr$REF) != 1) | (nchar(tab.chr$ALT) != 1)),
            " INDELs\n")
        
        ukbb.rejected.snpIDs <-
            c(ukbb.rejected.snpIDs, 
              tab.chr$snpID[(nchar(tab.chr$REF) != 1) |
                            (nchar(tab.chr$ALT) != 1)])
    }

    # combine
    tab.chr <-
        cbind(tab.chr, CHR=chr, CHR.POS=paste(chr, tab.chr$BP, sep=":"),
              AAF=AAF.chr,
              stringsAsFactors=FALSE)

    tab <- rbind(tab, tab.chr[!(tab.chr$snpID %in% ukbb.rejected.snpIDs), ])
}

ukbb <- cbind(tab,
              refalt=paste(tab$CHR, ":", tab$BP, "_", tab$REF, "_", tab$ALT,
                           sep=''),
              stringsAsFactors=FALSE)
rm(tab)

cat(nrow(ukbb), " UK Biobank variants ready\n")

# Finding the overlap
summstats <- summstats[ (summstats$a1a2 %in% ukbb$refalt) |
                        (summstats$a2a1 %in% ukbb$refalt), ]

ukbb.nonoverlapping <-
    setdiff(ukbb$refalt, union(summstats$a1a2, summstats$a2a1))

if (length(ukbb.nonoverlapping) > 0) {
    ukbb.rejected.snpIDs <-
        c(ukbb.rejected.snpIDs,
          ukbb$snpID[ukbb$refalt %in% ukbb.nonoverlapping])

    ukbb <- ukbb[!(ukbb$refalt %in% ukbb.nonoverlapping), ]
}

cat(nrow(summstats), "variants overlapping between UKBB and summary stats\n")


# Tri-allelic
triallelic.chr.pos <-
    ukbb$CHR.POS[duplicated(ukbb$CHR.POS)]

if (any(duplicated(ukbb$CHR.POS))) {
    cat("Removing", length(triallelic.chr.pos),
        "tri-allelic or duplicated markers\n")

    summstats <- summstats[ !(summstats$chr.pos %in% triallelic.chr.pos), ]

    ukbb.rejected.snpIDs <-
        c(ukbb.rejected.snpIDs, 
          ukbb$snpID[ ukbb$CHR.POS %in% triallelic.chr.pos ])
}

cat(nrow(summstats), "variants remain\n")
    
# Reordering
ukbb <- ukbb[order(ukbb$CHR.POS), ]
summstats <- summstats[order(summstats$chr.pos), ]

ASSERT(nrow(ukbb) == nrow(summstats))
ASSERT(all(ukbb$CHR.POS == summstats$chr.pos))
ASSERT(all( (ukbb$REF == summstats$a1 & ukbb$ALT == summstats$a2) |
            (ukbb$REF == summstats$a2 & ukbb$ALT == summstats$a1) ))
    

# harmonize alleles 
reffreq <- rep(NA, nrow(summstats))
effalt <- rep(NA, nrow(summstats))

# the eff allele is ALT
is.alt.eff.allele <- (ukbb$ALT == summstats$effal)
reffreq[is.alt.eff.allele] <- (1 - summstats$effaf[is.alt.eff.allele])
effalt[is.alt.eff.allele] <- summstats$effbeta[is.alt.eff.allele]

# the eff allele is REF
is.ref.eff.allele <- (ukbb$REF == summstats$effal)
reffreq[is.ref.eff.allele] <- summstats$effaf[is.ref.eff.allele]
effalt[is.ref.eff.allele] <- -summstats$effbeta[is.ref.eff.allele]

# = 0
ASSERT(all(!is.na(effalt)))

cat(sum(is.ref.eff.allele), "SNPs use REF alleles as effect alleles\n")
cat(sum(is.alt.eff.allele), "SNPs use ALT alleles as effect alleles\n")
cat("Fraction of SNPs with negative effalt:", mean(effalt < 0), "\n")

if ("effaf" %in% colnames(summstats)) {
    ASSERT(all(!is.na(summstats$effaf)))
    ASSERT(all(!is.na(reffreq)))
    ASSERT(all(!is.na(ukbb$AAF)))

    cat("Checking allele frequency differences between GWAS and UKBB...\n")

    af.mismatch <- ( abs(reffreq - (1 - ukbb$AAF)) > 0.1 )

    cat(sum(af.mismatch), "SNPs have AF differences > 0.1 (removed)\n")
    
    ukbb.rejected.snpIDs <-
        c(ukbb.rejected.snpIDs, ukbb$snpID[af.mismatch])

    summstats <- summstats[!af.mismatch, ]
    ukbb <- ukbb[!af.mismatch, ]
    reffreq <- reffreq[!af.mismatch]
    effalt <- effalt[!af.mismatch]

    cat(nrow(summstats), " variants pass the final check\n")

} else {
    cat("Filling in discovery GWAS reffreq with UKBB AF\n")
    
    refreq <- (1 - ukbb$AAF)
    ASSERT(all(!is.na(reffreq)))
}


rejectedSNPfile <- paste(workdir, "/", cohortname, ".UKBB_rejected_SNPIDs",
                         sep='')

cat("Saving rejected UKBB SNP IDs to", rejectedSNPfile, "...")

write.table(data.frame(SNPs=unique(ukbb.rejected.snpIDs), 
                       stringsAsFactors=FALSE), 
            file=rejectedSNPfile, row.names=FALSE, 
            col.names=FALSE, quote=FALSE, sep="\t")

cat("OK\n")

# Generate pre-formatted summstat file
outfile <-
    paste(workdir, "/", cohortname, ".preformatted_summstats.txt", sep='')

cat("Saving preformatted summary stats file to", outfile, "...")

df <- data.frame(chr=paste("chr", ukbb$CHR, sep=''), 
                 pos=ukbb$BP, 
                 ref=ukbb$REF, 
                 alt=ukbb$ALT, 
                 reffreq=reffreq, 
                 info=ukbb$INFO, 
#                 rs=ukbb$rsID, 
                 rs=ukbb$snpID, 
                 pval=summstats$pval, 
                 effalt=effalt, stringsAsFactors=FALSE)

# sort 
df.sorted <- df[df$chr == "chr1", ] 
df.sorted <- df.sorted[order(df.sorted$pos), ]

for (chr in 2:22) {
    df.chr <- df[df$chr == paste("chr", chr, sep=''), ]
    df.chr <- df.chr[order(df.chr$pos), ]

    df.sorted <- rbind(df.sorted, df.chr)
}

write.table(df.sorted, file=outfile, 
            row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")

cat("OK\n")
cat("Done\n")
