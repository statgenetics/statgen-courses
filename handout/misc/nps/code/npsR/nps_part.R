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

#########################################################################

cargs <- commandArgs(trailingOnly=TRUE)

if (length(cargs) != 3) {
    stop("Usage: Rscript nps_part.R <work dir> <chrom> <WINSHIFT>")
}

tempprefix <- paste(cargs[1], "/", sep='')

# Read in saved settings
args <- readRDS(paste(tempprefix, "args.RDS", sep=''))
WINSZ <- args[["WINSZ"]]


CHR <- as.numeric(cargs[2])

if (!(CHR %in% 1:22)) {
    stop("invalid chrom", CHR)
}

WINSHIFT <- as.numeric(cargs[3])

if (is.nan(WINSHIFT) || WINSHIFT < 0 || WINSHIFT >= WINSZ) {
    stop("Invalid shift:", cargs[3])
}

#########################################################################

# Load partition data 
part <- readRDS(paste(tempprefix, "win_", WINSHIFT, ".part.RDS", sep=''))

Nt <- part[["Nt"]]
nLambdaPT <- part[["nLambdaPT"]]
nEtaPT <- part[["nEtaPT"]]

lambda.q <- part[["lambda.q"]]
betahatH.q <- part[["betahatH.q"]]


trPT <- array(0, dim=c(Nt, nLambdaPT, nEtaPT, 1))    

print(CHR)
    
I <- 1

winfilepre <-
    paste(tempprefix, "win_", WINSHIFT, ".", CHR, ".", I, sep='')

while (file.exists(paste(winfilepre, ".pruned", ".table", sep=''))) {

    print(I)
    
    windata <- readRDS(paste(winfilepre, ".RDS", sep=''))

    tailfixfile <- paste(winfilepre, ".pruned", ".table", sep='')
    
    wintab <- read.delim(tailfixfile, header=TRUE, sep="\t")

    lambda0 <- wintab$lambda
    etahat0 <- wintab$etahat
    
    Nq <- sum(lambda0 > 0) 

    if (Nq == 0) {
        # move on to next iteration
        I <- I + 1
        
        winfilepre <-
            paste(tempprefix, "win_", WINSHIFT, ".", CHR, ".", I, sep='')
        next
    }

    QX0 <- windata[["Q0.X"]]

    etahat0 <- etahat0[lambda0 > 0]
    QX0 <- QX0[, lambda0 > 0, drop=FALSE]
    lambda0 <- lambda0[lambda0 > 0]
    
    ASSERT(nrow(QX0) == Nt)
    ASSERT(ncol(QX0) == Nq)
    
    for (Iq in 1:Nq) {
        QX0[, Iq] <- QX0[, Iq] * etahat0[Iq]
    }
    
    for (Il in 1:nLambdaPT) {
        
        lambda.lo <- lambda.q[Il]
        lambda.hi <- lambda.q[Il+1]
        in.lambda.bin <- lambda0 > lambda.lo & lambda0 <= lambda.hi
        
        for (Je in 1:nEtaPT) {
            
            betahatH.lo <- betahatH.q[Je, Il]
            betahatH.hi <- betahatH.q[Je+1, Il]
            in.betahatH.bin <-
                (in.lambda.bin & 
                 abs(etahat0) > betahatH.lo & abs(etahat0) <= betahatH.hi)
            
            if (any(in.betahatH.bin)) {
                
                trPT[, Il, Je, 1] <- trPT[, Il, Je, 1] + 
                    apply(QX0[, in.betahatH.bin, drop=FALSE], 1, sum)
            }
        }            
    }
    
    # move on to next iteration
    I <- I + 1
    
    winfilepre <-
        paste(tempprefix, "win_", WINSHIFT, ".", CHR, ".", I, sep='')
    
}

# save
saveRDS(trPT,
        file=paste(tempprefix, "win_", WINSHIFT, ".trPT.", CHR, ".RDS",
                   sep=''))

cat("Done\n")
