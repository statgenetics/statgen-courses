VERSION <- "1.1"

cat("Non-Parametric Shrinkage", VERSION, "\n")

args <- commandArgs(trailingOnly=TRUE)

if (length(args) != 7) {
    cat("Usage: Rscript nps_init.R <summary stats file> <train dir> <train fam file> <train pheno file> <train dataset ID> <window size> <work dir>\n")
    stop("")
}

summstatfile <- args[1]
traindir <- args[2]
trainfamfile <- args[3]
trainphenofile <- args[4]
traintag <- args[5]
WINSZ <- as.numeric(args[6])

if (is.nan(WINSZ) || WINSZ <= 10) {
    stop(paste("Invalid or too small window size:", args[6]))
}

tempprefix <- paste(args[7], "/", sep='')


#################################################################
# SANITY CHECKS

if (!file.exists(summstatfile)) {
    stop("File does not exists:", summstatfile)
}

if (!dir.exists(traindir)) {
   stop("Directory does not exists:", traindir)
}

if (!file.exists(trainfamfile)) {
   stop("File does not exists:", trainfamfile)
}

if (!file.exists(trainphenofile)) {
   stop("File does not exists:", trainphenofile)
}

summstat <- read.delim(summstatfile, header=TRUE, stringsAsFactors=FALSE,
                       sep="\t")
# dim(summstat)

if (length(intersect(colnames(summstat), 
                     c("chr", "pos", "ref", "alt", "reffreq", "pval",
                       "effalt"))) 
    != 7) {
    cat(paste(colnames(summstat), collapse="\t"), "\n")
    cat("Expected essential columns: ",
        paste(c("chr", "pos", "ref", "alt", "reffreq", "pval", "effalt"),
              collapse="\t"), "\n")
    stop("Missing essential columns:", summstatfile)
}

if (nchar(summstat$chr[1]) < 4 || substr(summstat$chr[1], 1, 3) != "chr") {
    stop("Chromosome names are expected to be chr1, ..., chr22:", summstatfile)
}

summstat.chr <- substr(summstat$chr, 4, nchar(summstat$chr))

if (length(setdiff(summstat.chr, as.character(1:22))) != 0) {
    cat(paste(setdiff(summstat.chr, as.character(1:22)), collapse=", "), "\n")
    stop("expect only chr1 through chr22:", summstatfile)
}

summstat.chr <- as.numeric(summstat.chr)

if (is.unsorted(summstat.chr)) {
    stop("Not sorted by chr:", summstatfile)
}

for (CHR in 1:22) {
    if (is.unsorted(summstat$pos[summstat.chr == CHR])) {
        stop("chr", CHR, ": not sorted by pos:", summstatfile)
    }

    if (any(duplicated(summstat$pos[summstat.chr == CHR]))) {
        summstat0 <- summstat[summstat.chr == CHR, ]
        dup.pos <- duplicated(summstat0$pos)
        print(head(summstat0[summstat0$pos %in% dup.pos, ]))
            
        stop("chr", CHR, ": duplicated pos or tri-allelic:", summstatfile)
    }
}

if (any(is.na(summstat$reffreq))) {
    stop("NA in reffreq:", summstatfile)
}

if (any(is.na(summstat$effalt))) {
    stop("NA in effalt:", summstatfile)
}

if (any(is.na(summstat$pval))) {
    stop("NA in pval:", summstatfile)
}

if (any(summstat$pval == 0)) {
    stop("pval underflow (pval == 0):", summstatfile)
}

if (any(nchar(summstat$ref) != 1) || any(nchar(summstat$alt) != 1)) {
    stop("InDels are not allowed:", summstatfile)
}

summstat.SNPID <- paste(summstat.chr, ":", summstat$pos,
                        "_", summstat$ref, "_", summstat$alt,
                        sep='')

if (!dir.exists(tempprefix)) {
    dir.create(tempprefix)
}

if (!dir.exists(paste(tempprefix, "/log", sep=''))) {
    dir.create(paste(tempprefix, "/log", sep=''))
} else {
    log.files <- paste(tempprefix, "/log", "/nps_*.Rout.*", sep='')
    cat("Removing log files: ", log.files, "...")
    unlink(log.files)
    cat(" OK\n")
}


# train allele freq
trfrq.combined <- NULL

trainfreqfile <-
    paste(tempprefix, "/", traintag, ".meandos", sep='')

# snp info
trSNPID <- c()

for (CHR in 1:22) {

    # Read train allele freq
    meandosfile <-
        paste(traindir, "/chrom", CHR, ".", traintag, ".meandos", sep='')

    trfrq <- read.table(meandosfile, header=TRUE, stringsAsFactors=FALSE)
    
    if (length(colnames(trfrq)) != 2 ||
        any(colnames(trfrq) != c("SNPID", "AAF"))) {

        stop("Invalid .meandos header: ", meandosfile)
    }

    # Save AAF
    trainfreqfile.chr <- paste(trainfreqfile, ".", CHR, sep='')
        
    cat("Copying training AAF file to: ", trainfreqfile.chr, "...")

    write.table(trfrq, file=trainfreqfile.chr,
                sep="\t", row.names=FALSE, col.names=TRUE, quote=FALSE)

    cat(" OK\n")

    trfrq.combined <- rbind(trfrq.combined, trfrq)

    # Read SNP infos
    snpinfofile <-
        paste(traindir, "/chrom", CHR, ".", traintag, ".snpinfo", sep='')

    snpinfo <- read.table(snpinfofile, header=TRUE, stringsAsFactors=FALSE)

    trSNPID.chr <- paste(snpinfo$chromosome, ":", snpinfo$position,
                         "_", snpinfo$alleleA, "_", snpinfo$alleleB,
                         sep='')

    if (any(!(trSNPID.chr %in% summstat.SNPID))) {
        cat(paste(setdiff(trSNPID.chr, summstat.SNPID), collapse="\n"), "\n")
        stop("Missing summary statistics for the above SNPs in training cohort")
    }

    trSNPID <- c(trSNPID, trSNPID.chr)
}

summstat <- summstat[summstat.SNPID %in% trSNPID, ]
summstat.SNPID <- summstat.SNPID[summstat.SNPID %in% trSNPID]

if (nrow(trfrq.combined) != nrow(summstat)) {
    print(nrow(summstat))
    print(nrow(trfrq.combined))
    stop("The number of markers does not match:", summstatfile, ", ", 
         paste(traindir, "/chromXX.", traintag, ".meandos", sep=''))
}

if (length(trSNPID) != nrow(summstat)) {
    print(nrow(summstat))
    print(length(trSNPID))
    stop("The number of markers does not match:", summstatfile, ", ", 
         paste(traindir, "/chromXX.", traintag, ".snpinfo", sep=''))
}

if (any(trSNPID != summstat.SNPID)) {
    cat(head(data.frame(summstat=summstat.SNPID, train=trSNPID,
                        stringsAsFactors=FALSE)[trSNPID != summstat.SNPID, ]))
    
    stop("Alleles does not align:", summstatfile, ", ",
         paste(traindir, "/chromXX.", traintag, ".snpinfo", sep=''))
}

trfam <- read.delim(trainfamfile, sep=" ", header=FALSE,
                    stringsAsFactors=FALSE)

trphen <- read.delim(trainphenofile, sep="\t", header=TRUE,
                     stringsAsFactors=FALSE)

if (ncol(trfam) != 6) {
    # re-try with tab delimination

    trfam <- read.delim(trainfamfile, sep="\t", header=FALSE,
                        stringsAsFactors=FALSE)
}

if (ncol(trfam) != 6) {    
    stop("Space or tab-delimited 6-column FAM format expected:", trainfamfile)
}

if (length(intersect(colnames(trphen), 
                     c("FID", "IID", "Outcome"))) 
    != 3) {

    stop("FID\tIID\tOutcome columns expected (tab-delimited):", trainphenfile)
}

Nt <- nrow(trfam)

if (Nt <= 1) {
    stop("Invalid training cohort size:", Nt)
}

if (Nt < 1000) {
    cat("Warning: Training cohort may be too small: ", Nt)
}

rownames(trphen) <- paste(trphen$FID, trphen$IID, sep=":")

missing.famIDs <- 
    setdiff(paste(trfam[, 1], trfam[, 2], sep="\t"),
            paste(trphen$FID, trphen$IID, sep="\t"))

if (length(missing.famIDs) > 0) {
    cat(paste(missing.famIDs, collapse="\n"))
    stop("Missing phenotypes for samples in ", trainfamfile, ":",
         trainphenofile)
}

if (any(is.na(trphen$Outcome))) {
    stop("NA not allowed in Outcome:", trainphenofile)
}

if (length(unique(trphen$Outcome)) > 3) {
    # Quantitative phenotypes
    cat("Quantitative phenotype: Outcome\n")

    if (!is.numeric(trphen$Outcome)) {
        stop("phenotype values are not numeric: Outcome :", trainphenofile)
    }

    if (any(trphen$Outcome == -9)) {
        stop("NA (\"-9\") not allowed in Outcome (instead use \"-9.00001\" for a quantitative trait value):", trainphenofile)
    }

} else {
    # Binary phenotypes    
    cat("Binary phenotype: Outcome\n")

    if (any(trphen$Outcome == -9)) {
        stop("NA (\"-9\") not allowed in Outcome:", trainphenofile)
    }

    if (length(setdiff(trphen$Outcome, c(0, 1))) != 0) {
        print(head(trphen[!(trphen$Outcome %in% c(0, 1)), ]))
        stop("Only 0 or 1 is expected in Outcome:", trainphenofile)
    }

    if (sum(trphen$Outcome == 0) == 0) {
        stop("Must have controls (Outcome = 0):", trainphenofile)
    }

    if (sum(trphen$Outcome == 1) == 0) {
        stop("Must have cases (Outcome = 1):", trainphenofile)
    }
}

##################################################################
# SAVE

# Save summary statistics
summstatfile2 <- paste(tempprefix, "/harmonized.summstats.txt", sep='')

cat("Dumping harmonized summary stats file: ", summstatfile2, "...")

write.table(summstat[, c("chr", "pos", "ref", "alt", "reffreq", "pval",
                         "effalt")],
            file=summstatfile2, quote=FALSE, sep="\t",
            row.names=FALSE, col.names=TRUE)
cat(" OK\n")

# SAve config
cat("Writing config file ...")

args <- list()

args[["VERSION"]] <- VERSION
args[["summstatfile"]] <- summstatfile2
args[["Nt"]] <- Nt
args[["traindir"]] <- traindir
args[["trainfamfile"]] <- trainfamfile
args[["trainfreqfile"]] <- trainfreqfile
args[["trainphenofile"]] <- trainphenofile
args[["traintag"]] <- traintag
args[["WINSZ"]] <- WINSZ
# Fixed cut-off for lambda of projection
# args[["LAMBDA.CO"]] <- 10
# Cut-off for corss-window pruning
args[["CXWCOR.CO"]] <- 0.3

saveRDS(args, file=paste(tempprefix, "args.RDS", sep=''))
cat(" OK\n\n")

print(args)

cat("Done\n")
