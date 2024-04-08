VERSION <- "1.1"

cat("Non-Parametric Shrinkage", VERSION, "\n")

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

w.quant.o2 <- function(x, nbin) {

    ASSERT(all(x >= 0))
    ASSERT(all(!is.na(x)))

    x <- sort(x, decreasing=FALSE)

    w <- x / sum(x)                     # normalize
    
    sum.wx <- cumsum(w * x)

    cuts <- sum(w * x) * (1:(nbin - 1) / nbin)

    q <- c()

    for (cx in cuts) {
        xL <- max(x[sum.wx < cx])
        xR <- min(x[sum.wx > cx])
        q <- c(q, (xL + xR)/2)
    }
    
    c(min(x), q, max(x))

}

#########################################################################
# tempprefix <- "~/ukbb.ibd/npsdat2/"
# nLambdaPT <- 10
# nEtaPT <- 10

cargs <- commandArgs(trailingOnly=TRUE)

if (length(cargs) < 3) {
    stop("Usage: Rscript nps_prep_part.R <work dir> <N of eigenvalue partitions> <N of eta hat partitions> [<winshift> ...]")
}

tempprefix <- paste(cargs[1], "/", sep='')

args <- readRDS(paste(tempprefix, "args.RDS", sep=''))

Nt <- args[["Nt"]]
WINSZ <- args[["WINSZ"]]

nLambdaPT <- as.numeric(cargs[2])
nEtaPT <- as.numeric(cargs[3])

if (is.nan(nLambdaPT) || nLambdaPT < 1) {
    stop("Invalid nLambdaPT:", cargs[2])
}

if (is.nan(nEtaPT) || nEtaPT < 1) {
    stop("Invalid nEtaPT:", cargs[3])
}


if (length(cargs) > 3) {

    WINSHIFT.list <- as.numeric(cargs[4:length(cargs)])

} else {

    cat("Detecting window shifts :")

    part.files <- list.files(tempprefix, pattern="*.Q.RDS")
        
    WINSHIFT.list <-
        sapply(part.files,
               function (s) strsplit(s, ".", fixed=TRUE)[[1]][1],
               simplify=TRUE)

    WINSHIFT.list <- unique(WINSHIFT.list)

    WINSHIFT.list <-
        sapply(WINSHIFT.list,
               function (s) strsplit(s, "_", fixed=TRUE)[[1]][2],
               simplify=TRUE)

    WINSHIFT.list <- sort(as.numeric(WINSHIFT.list))

    cat(paste(WINSHIFT.list, collapse=" "), "\n")
}

if (any(is.nan(WINSHIFT.list)) || any(WINSHIFT.list < 0) ||
    any(WINSHIFT.list >= WINSZ)) {

    if (length(cargs) > 3) {
        stop("Invalid shift (window size =", WINSZ, "):",
             cargs[4:length(cargs)])
    } else {
        stop("Invalid shift (window size =", WINSZ, "):",
             WINSHIFT.list)
    }
}


#############################################################################

for (WINSHIFT in WINSHIFT.list) {

    cat("----- Shifted by", WINSHIFT, "-----\n")
    
    etahat.all <- c()
    eval.all <- c()                         # lambda (eigenvalue)
    
    # chrom <- 1

    for (chrom in 1:22) {
        cat("chrom", chrom, "\n")
        
        I <- 1

        winfilepre <-
            paste(tempprefix, "win_", WINSHIFT, ".", chrom, ".", I,
                  sep='')
        
        while (file.exists(paste(winfilepre, ".pruned", ".table", sep=''))) {
            
            tailfixfile <- paste(winfilepre, ".pruned", ".table", sep='')
            
            wintab <- read.delim(tailfixfile, header=TRUE, sep="\t")

            lambda0 <- wintab$lambda
            etahat0 <- wintab$etahat
            
            if (sum(lambda0 > 0) > 0) {
                etahat0 <- etahat0[lambda0 > 0]
                lambda0 <- lambda0[lambda0 > 0]
                
                etahat.all <- c(etahat.all, etahat0)
                eval.all <- c(eval.all, lambda0)
            }
        
            ## move on to next iteration
            I <- I + 1

            winfilepre <-
                paste(tempprefix, "win_", WINSHIFT, ".", chrom, ".", I, sep='')
        }
    }
    
    cat("\n\n\n")
    cat("Start partitioning:")
    cat("Total number of eigenlocus projections:", length(etahat.all), "\n")

######
## Partition by lambda 
## variance scale to sd scale

    lambda.all <- eval.all

    cat("Total number of eigenlocus projections:", length(etahat.all), "\n")

    lambda.q <- w.quant.o2(sqrt(lambda.all), nLambdaPT)
    lambda.q <- lambda.q ** 2
    lambda.q[1] <- 0
    lambda.q[nLambdaPT + 1] <- lambda.q[nLambdaPT + 1] * 1.1
    
    cat("Partition cut-offs on intervals of eigenvalues:\n")
    print(lambda.q)
    

######
## Partition by eta hat (betahat_H)

    betahatH.q <- matrix(NA, nrow=(nEtaPT + 1), ncol=nLambdaPT)

    count <- 0
    nBetahatH <- array(0, dim=c(nLambdaPT, nEtaPT, 1))
    meanBetahatH <- array(0, dim=c(nLambdaPT, nEtaPT, 1))
    
    for (I in 2:length(lambda.q)) {
        etahat.all.sub <- etahat.all[lambda.all > lambda.q[I - 1] &
                                     lambda.all <= lambda.q[I]]
        etahat.all.sub <- abs(etahat.all.sub)
        
        betahatH.q[, I - 1] <- w.quant.o2(etahat.all.sub, nEtaPT)
        betahatH.q[1, I - 1] <- 0
        betahatH.q[nEtaPT + 1, I - 1] <- betahatH.q[nEtaPT + 1, I - 1] * 1.1 
        
        for (J in 1:nEtaPT) {
            
            betahatH.lo <- betahatH.q[J, I - 1]
            betahatH.hi <- betahatH.q[J+1, I - 1]
#        print(sum(etahat.all.sub > betahatH.lo &
#                  etahat.all.sub <= betahatH.hi))

            nBetahatH[I - 1, J, 1] <- nBetahatH[I - 1, J, 1] +
                sum(etahat.all.sub > betahatH.lo &
                    etahat.all.sub <= betahatH.hi)
            meanBetahatH[I - 1, J, 1] <- meanBetahatH[I - 1, J, 1] +
                sum(etahat.all.sub[(etahat.all.sub > betahatH.lo &
                                    etahat.all.sub <= betahatH.hi)])
            
            count <- count + sum(nBetahatH[I - 1, J, ])
        }
    }

    ASSERT((count + sum(etahat.all == 0)) == length(lambda.all))

    cat("Partition cut-offs on intervals on eta-hat:\n")
    print(betahatH.q)
    
    meanBetahatH <- meanBetahatH / nBetahatH
    
    meanBetahatH[is.nan(meanBetahatH)] <- 0

# print(meanBetahatH)


    ## Save partition boundaries 
    partdata <- list()
    
    partdata[["Nt"]] <- Nt
    partdata[["nLambdaPT"]] <- nLambdaPT
    partdata[["nEtaPT"]] <- nEtaPT
    
    partdata[["nVars"]] <- nBetahatH

    partdata[["lambda.q"]] <- lambda.q
    partdata[["betahatH.q"]] <- betahatH.q
    partdata[["meanBetahatH"]] <- meanBetahatH

    saveRDS(partdata,
            paste(tempprefix, "win_", WINSHIFT, ".part.RDS", sep=''))

#    save.image(file=paste(tempprefix, "nps_prep_part.", "win_", WINSHIFT,
#                          ".RData",
#                          sep=''))

    cat("OK\n")
}

cat("Done\n")
