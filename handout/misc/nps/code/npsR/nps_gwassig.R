VERSION <- "1.1"

cat("Non-Parametric Shrinkage", VERSION, "\n")

# P-value threshold for the GWAS-significant tail partition
TAIL.THR <- 5E-8
TAIL.THR.Z <- abs(qnorm(TAIL.THR/2, lower.tail=TRUE))

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

#########################################################################

cargs <- commandArgs(trailingOnly=TRUE)

if (length(cargs) != 2) {
    stop("Usage: Rscript nps_split_gwassig.R <work dir> <chrom>")
}

tempprefix <- paste(cargs[1], "/", sep='')

# Read in saved settings
args <- readRDS(paste(tempprefix, "args.RDS", sep=''))

Nt <- args[["Nt"]]
summstatfile <- args[["summstatfile"]] 
traindir <- args[["traindir"]] 
traintag <- args[["traintag"]]
WINSZ <- args[["WINSZ"]]

# Rest of command args
CHR <- as.numeric(cargs[2])

if (!(CHR %in% 1:22)) {
    stop("invalid chrom", CHR)
}

if (CHR == 6) {
    WINSZ <- WINSZ * 2
}
#########################################################################

# Read summary stats (discovery)
chr.str <- paste('chr', CHR, sep='')

summstat <- read.delim(summstatfile, header=TRUE, stringsAsFactors=FALSE,
                       sep="\t")

summstat <- summstat[summstat$chr == chr.str, ]
M.chr <- nrow(summstat)

std.effalt <-
    abs(qnorm(summstat$pval/2, lower.tail=TRUE))*sign(summstat$effalt)

if ("N" %in% colnames(summstat)) {
    
    sqrtN <- sqrt(summstat$N)

} else {
    
    ## Calculate effective N
    se <- sqrt(2 * summstat$reffreq * (1 - summstat$reffreq))
    sqrtN <- std.effalt / (summstat$effalt * se)
    sqrtN[summstat$effalt == 0] <- 0
}

summstat <- cbind(summstat, std.effalt=std.effalt, sqrtN=sqrtN)

summstat.chr <- summstat

#####
## Scan starting from the most associated SNPs

X0 <- NULL
ld0 <- NULL

start.idx <- c()
end.idx <- c()
betahat.tail.chr <- rep(0, M.chr)

pval.chr <- summstat.chr$pval

# for trPT of tails 
X.trPT <- NULL
betahat.trPT <- c()

masked <- rep(5, M.chr) # analyzed up to 5 times 
masked[ summstat.chr$sqrtN == 0 ] <- 0
    
while (max(abs(summstat.chr$std.effalt[masked > 0])) > TAIL.THR.Z) {

    ## Focal SNP
    ##    pick0 <- which.min(pval.chr)[1]
    masked.std.effalt <- abs(summstat.chr$std.effalt)
    masked.std.effalt[masked <= 0] <- 0
    pick0 <- which.max(masked.std.effalt)
    pick.chrpos <- summstat.chr$pos[pick0]

    cat(pick.chrpos, ": marginal p =", pval.chr[pick0], " beta.std =",
        summstat.chr$std.effalt[pick0], "\n")

    begin <- max(pick0 - WINSZ, 1)
    end <- min(pick0 + WINSZ, M.chr)

    cat("[", begin, "]", summstat.chr$pos[begin], "-",
        "[", end, "]", summstat.chr$pos[end], "\n")

    start.idx <- c(start.idx, begin)
    end.idx <- c(end.idx, end)

    ## Get the reference LD matrix
    stdgt.file <-
        gzfile(paste(traindir, "/chrom", CHR, ".", traintag,
                     ".stdgt.gz", sep=''), open="rb")
    
    ## Seek to the "begin" pos
    X2 <- 1

    while ( (X2 + 1000) < begin ) {
        readBin(stdgt.file, "double", n=(Nt*1000))
        X2 <- X2 + 1000
    }
        
    while (X2 < begin) {
        readBin(stdgt.file, "double", n=Nt)
        X2 <- X2 + 1
    }
    
    ASSERT(X2 == begin)

    ## Read training genotypes
    span <- (end - begin + 1)
    X0v <- readBin(stdgt.file, "double", n=(span * Nt))
    X0 <- matrix(X0v, nrow=Nt, ncol=span)
    ## Re-standardize by sd
    X0 <- X0 / matrix(apply(X0, 2, sd),
                      byrow=TRUE, nrow=nrow(X0), ncol=ncol(X0))
    rm(X0v)
    
    close(stdgt.file)

    ld0 <- (t(X0) %*% X0) / (Nt - 1)

    ## SE ~ 1/sqrt(Nt), 5 SD
    ld0[abs(ld0) < 5 / sqrt(Nt)] <- 0

    span <- (end - begin + 1)

    ASSERT(!is.null(X0))
    ASSERT(nrow(X0) == Nt)
    ASSERT(ncol(X0) == span)

    ASSERT(!is.null(ld0))
    ASSERT(nrow(ld0) == span)

    pos.win <- summstat.chr$pos[begin:end]

    ## LD-adjust the std.effalt around the focal SNP
    ## Treat the tail effect as a fixed effect and correct it
    betahat.win <- summstat.chr$std.effalt[begin:end]
    sqrtN.win <- summstat.chr$sqrtN[begin:end]
    pick1 <- pick0 - begin + 1

    ASSERT(pos.win[pick1] == pick.chrpos)

    ## calculate residual effects
    tailbeta <- rep(0, span)
    tailbeta[pick1] <- betahat.win[pick1]

    ## N correction
    ASSERT(sqrtN.win[pick1] != 0)
    sqrtN.cor <- sqrtN.win / sqrtN.win[pick1]

    betahat.win.tailfix <-
        betahat.win - sqrtN.cor * (ld0 %*% as.matrix(tailbeta))

    ## masked.win <- masked[begin:end]
    ## masked.win[abs(ld0[pick1, ]) > 0.5] <- TRUE

    ## if (max(abs(betahat.win.tailfix)[!masked.win]) > TAIL.THR.Z) {
    ##     ## calculate joint effects

    ##     betahat.win.tailfix2 <- abs(betahat.win.tailfix)
    ##     betahat.win.tailfix2[masked.win] <- 0
        
    ##     pick2cv <- which.max(betahat.win.tailfix2)

    ##     r.ij <- ld0[pick1, pick2cv]
    ##     det.ij <- 1 - r.ij**2

    ##     if (r.ij != 0) {
            
    ##         lambda.i <-
    ##             (betahat.win[pick1] - r.ij * sqrtN.win[pick1] /
    ##              sqrtN.win[pick2cv] * betahat.win[pick2cv]) / det.ij

    ##         cat("    (", pos.win[pick1], pos.win[pick2cv], ") r =",
    ##             r.ij, "Z =", betahat.win[pick1], "->", lambda.i, "\n")
                
    ##         tailbeta[pick1] <- lambda.i

    ##         betahat.win.tailfix <-
    ##             betahat.win - sqrtN.cor * (ld0 %*% as.matrix(tailbeta))
    ##     }
    ## }

    cat("Residualizing the effect at", pos.win[pick1],
        "Z =", tailbeta[pick1], "\n")

    betahat.tail.chr[pick0] <- tailbeta[pick1]
    X.trPT <- cbind(X.trPT, X0[, pick1])
    betahat.trPT <- c(betahat.trPT, tailbeta[pick1])

    ASSERT(all(!is.na(betahat.win.tailfix)))
    
    ## update 
    summstat.chr$std.effalt[begin:end] <- betahat.win.tailfix

    ## Mask out LD neighbors of focal SNPs from being selected as
    ## next focal SNPs

    masked[begin:end] <- masked[begin:end] - 1
    
    pos.mask <- pos.win[abs(ld0[pick1, ]) > 0.3]
    masked[summstat.chr$pos %in% pos.mask] <- 0

    cat("Max Residualized Z:",
        max(abs(betahat.win.tailfix)[masked[begin:end] > 0]),
        "\n")
    
    ## clean up previous run
    rm(X0)
    rm(ld0)
    gc()
}

print(data.frame(start=summstat.chr$pos[start.idx],
                 end=summstat.chr$pos[end.idx],
                 bp=(summstat.chr$pos[end.idx] - summstat.chr$pos[start.idx])))

## Save betahat info for the tail partition

write.table(data.frame(betahat.tail.chr),
            file=paste(tempprefix, "tail_betahat.", CHR, ".table",
                       sep=''),
            row.names=FALSE, col.names=FALSE, quote=FALSE, sep="\t")

## Save updated std.effalt

write.table(summstat.chr,
            file=paste(summstatfile, ".", CHR, sep=''),
            row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")

## Save tail 
if (length(betahat.trPT) > 0) {
    cat("Saving trPT for tail\n")
        
    ASSERT(nrow(X.trPT) == Nt)
    ASSERT(ncol(X.trPT) == length(betahat.trPT))

    prs.tail <- X.trPT %*% as.matrix(betahat.trPT)


} else {
    
    prs.tail <- rep(0, Nt)

}

ASSERT(length(prs.tail) == Nt)
    
saveRDS(prs.tail, file=paste(tempprefix, "trPT.", CHR, ".tail.RDS",
                             sep=''))

cat("Done\n")

