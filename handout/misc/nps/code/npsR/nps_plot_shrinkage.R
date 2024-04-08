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

if (length(cargs) < 2) {
    stop("Usage: Rscript nps_plot_shrinkage.R <work dir> <plot.pdf> [ <WINSHIFT> ...]")
}

tempprefix <- paste(cargs[1], "/", sep='')

# Read in saved settings
args <- readRDS(paste(tempprefix, "args.RDS", sep=''))

WINSZ <- args[["WINSZ"]]

plotfile <- cargs[2]
if (substr(plotfile, nchar(plotfile) - 3, nchar(plotfile)) != ".pdf") {
    stop("Invalid pdf file path:", plotfile)
}

if (length(cargs) > 2) {

    WINSHIFT.list <- as.numeric(cargs[3:length(cargs)])

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
    if (length(cargs) > 2) {
        stop("Invalid shift (window size =", WINSZ, "):",
             cargs[3:length(cargs)])
    } else {
        stop("Invalid shift (window size =", WINSZ, "):",
             WINSHIFT.list)
    }
}


cat("Write to: ", plotfile, "\n")
cat("Shifts by: ", paste(WINSHIFT.list, collapse=", "), "\n")

WINSHIFT <- WINSHIFT.list[1]

part <- readRDS(paste(tempprefix, "win_", WINSHIFT, ".part.RDS", sep=''))

nLambdaPT <- part[["nLambdaPT"]]
nEtaPT <- part[["nEtaPT"]]


#########################################################################

pdf(file=plotfile, useKerning=FALSE, useDingbats=FALSE)

x.end.Ix <- rep(0, nLambdaPT)
x.end.Ix.cap <- rep(NA, nLambdaPT)
y.end <- 0

for (WINSHIFT in WINSHIFT.list) {

    part <- readRDS(paste(tempprefix, "win_", WINSHIFT, ".part.RDS", sep=''))
    
    PTwt <- readRDS(paste(tempprefix, "win_", WINSHIFT, ".PTwt.RDS", sep=''))

    meanBetahatH <- part[["meanBetahatH"]]
    betahatH.q <- part[["betahatH.q"]]

    x.end.Ix <- pmax(x.end.Ix, meanBetahatH[, nEtaPT, 1] * 1.2)
    x.end.Ix.cap <- pmin(x.end.Ix.cap, betahatH.q[nEtaPT + 1, ], na.rm=TRUE)
    y.end <- max(y.end, max(abs(meanBetahatH[, , 1] * PTwt[, , 1])) * 1.2)

}

x.end <- max(x.end.Ix)

x.end.Ix <- x.end.Ix.cap


scale <- 1

PTwt.tail.file <- paste(tempprefix, "PTwt.tail.RDS", sep='')

ASSERT(file.exists(PTwt.tail.file))

PTwt.tail <- readRDS(PTwt.tail.file)

if (PTwt.tail > 0) {
    scale <- 1 / PTwt.tail
}

#    cat("Rescale y-axis by ", scale, "\n")


Ix <- nLambdaPT

for (Ix in nLambdaPT:1) {

    x.seq <- seq(0, min(x.end.Ix[Ix], x.end), min(x.end.Ix[Ix], x.end) / 100)
    y.seq <- rep(0, length(x.seq))

    for (WINSHIFT in WINSHIFT.list) {

        part <-
            readRDS(paste(tempprefix, "win_", WINSHIFT, ".part.RDS", sep=''))
        
        PTwt <-
            readRDS(paste(tempprefix, "win_", WINSHIFT, ".PTwt.RDS", sep=''))

        betahatH.q <- part[["betahatH.q"]]

        for (Jx in 1:nEtaPT) {
            Jx.st <- betahatH.q[Jx, Ix]
            Jx.ed <- betahatH.q[Jx + 1, Ix]
            wt <- PTwt[Ix, Jx, 1]

            seg <- x.seq >= Jx.st & x.seq < Jx.ed

            y.seq[seg] <- y.seq[seg] + wt * x.seq[seg]
        }
    }
    
    y.seq <- y.seq / 4 * scale

    # ignore the end point
    x.seq <- x.seq[1:(length(x.seq) - 1)]
    y.seq <- y.seq[1:(length(y.seq) - 1)]

    plot(x.seq, y.seq, ty='l',
         xlim=c(0, x.end),
         ylim=c(0, y.end * scale),
         main=paste("S_", Ix, ": ", Ix, "-th decile in eigenvalues", sep=''),
         xlab="eta hats", ylab="Conditional mean effects")

}

dev.off()
