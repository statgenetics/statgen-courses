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

if (length(cargs) < 1) {
    stop("Usage: Rscript nps_train_AUC.R <work dir> [ <WINSHIFT> ...]")
}

tempprefix <- paste(cargs[1], "/", sep='')

# Read in saved settings
args <- readRDS(paste(tempprefix, "args.RDS", sep=''))

WINSZ <- args[["WINSZ"]]
trainfamfile <- args[["trainfamfile"]]
trainphenofile <- args[["trainphenofile"]]

if (length(cargs) > 1) {

    WINSHIFT.list <- as.numeric(cargs[2:length(cargs)])

} else {

    cat("Detecting window shifts :")

    part.files <- list.files(tempprefix, pattern="*.part.RDS")
        
    WINSHIFT.list <-
        sapply(part.files,
               function (s) strsplit(s, ".", fixed=TRUE)[[1]][1],
               simplify=TRUE)

    WINSHIFT.list <-
        sapply(WINSHIFT.list,
               function (s) strsplit(s, "_", fixed=TRUE)[[1]][2],
               simplify=TRUE)

    WINSHIFT.list <- sort(as.numeric(WINSHIFT.list))

    cat(paste(WINSHIFT.list, collapse=" "), "\n")
}

if (any(is.nan(WINSHIFT.list)) || any(WINSHIFT.list < 0) ||
    any(WINSHIFT.list >= WINSZ)) {
    
    if (length(cargs) > 1) {
        stop("Invalid shift (window size =", WINSZ, "):",
             cargs[2:length(cargs)])
    } else {
        stop("Invalid shift (window size =", WINSZ, "):",
             WINSHIFT.list)
    }
}

#########################################################################

cat("trainfamfile:", trainfamfile, "\n")
cat("trainphenofile:", trainphenofile, "\n")

# phenotypes
trfam <- read.delim(trainfamfile, sep=" ", header=FALSE,
                    stringsAsFactors=FALSE)
trphen <- read.delim(trainphenofile, sep="\t", header=TRUE,
                     stringsAsFactors=FALSE)

if (ncol(trfam) != 6) {
    # re-try with tab delimination

    trfam <- read.delim(trainfamfile, sep="\t", header=FALSE,
                        stringsAsFactors=FALSE)
}

ASSERT(ncol(trfam) == 6)

rownames(trphen) <- paste(trphen$FID, trphen$IID, sep=":")
trphen <- trphen[paste(trfam[, 1], trfam[, 2], sep=":"), ]


#print(length(intersect(paste(trfam[, 1], trfam[, 2], sep=":"),
#                       paste(trphen$FID, trphen$IID, sep=":")
#                       )))
#print(sum(is.na(trphen$Outcome)))

ASSERT(all(!is.na(trphen$Outcome)))
ASSERT(all(trphen$FID == trfam[, 1]))
ASSERT(all(trphen$IID == trfam[, 2]))

trY <- trphen$Outcome

#########################################################################
# Read partitions

predY0 <- rep(0, length(trY))

# tail partition
trPT.tail <- rep(0, length(trY))

for (chrom in 1:22) {
    
    trPT.tail.file <-
        paste(tempprefix, "trPT.", chrom, ".tail.RDS", sep='')

    ASSERT(file.exists(trPT.tail.file))
    if (!file.exists(trPT.tail.file)) {
        next
    }
    
    cat("Loading S0 partition for chrom", chrom, "...\n")

    trPT.tail.chr <- readRDS(trPT.tail.file)
    
    trPT.tail <- trPT.tail + trPT.tail.chr

}

PTwt.tail <- readRDS(paste(tempprefix, "PTwt.tail.RDS", sep=''))

for (WINSHIFT in WINSHIFT.list) {

    cat("winshift =", WINSHIFT, "...\n")

    part <-
        readRDS(paste(tempprefix, "win_", WINSHIFT, ".part.RDS", sep=''))

    Nt <- part[["Nt"]]
    nLambdaPT <- part[["nLambdaPT"]]
    nEtaPT <- part[["nEtaPT"]]

    ASSERT(Nt == length(trY))

    trPT <- array(0, dim=c(Nt, nLambdaPT, nEtaPT, 1))    

    for (chrom in 1:22) {

        trPT.chr <-
            readRDS(paste(tempprefix, "win_", WINSHIFT, ".trPT.", chrom,
                          ".RDS", sep=''))

        trPT <- trPT + trPT.chr
    }


    PTwt <-
        readRDS(paste(tempprefix, "win_", WINSHIFT, ".PTwt.RDS", sep=''))


    for (I in 1:nLambdaPT) {
        for (J in 1:nEtaPT) {
            K <- 1
            
            predY0 <- predY0 + PTwt[I, J, K] * trPT[, I, J, K]
        }
    }

    predY0 <- predY0 + PTwt.tail * trPT.tail 

}

cat("\n\n\n")
cat("R^2 :\n")
cat(cor(trY, predY0)**2)
# print(cor.test(trY, predY0))

if (length(unique(trY)) > 2) {
    # Quantitative phenotypes
    cat("Quantitative phenotype: Outcome - Skip AUC calculation\n")
    
    # Done
} else {

    library(pROC)

    cat("AUC :\n")
    print(roc(cases=predY0[trY == 1], controls=predY0[trY == 0], ci=TRUE))
}
