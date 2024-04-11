
# R code for Manhattan plots (and QQ plots)
# See tutorial at http://gettinggeneticsdone.blogspot.com/2011/04/annotated-manhattan-plots-and-qq-plots.html

# Stephen Turner
# http://StephenTurner.us/
# http://GettingGeneticsDone.blogspot.com/
# See license at http://gettinggeneticsdone.blogspot.com/p/copyright.html
# Last updated: Tuesday, April19, 2011
# R code for making manhattan plots and QQ plots from plink output files. 
# manhattan() with GWAS data this can take a lot of memory, recommended for use on 64bit machines only, for now. 
# Altnernatively, use bmanhattan() , i.e., base manhattan. uses base graphics. way faster.
## This is for testing purposes.
# set.seed(42)
# nchr=23
# nsnps=1000
# d=data.frame(
# SNP=sapply(1:(nchr*nsnps), function(x) paste("rs",x,sep='')),
# CHR=rep(1:nchr,each=nsnps), 
# BP=rep(1:nsnps,nchr), 
# P=runif(nchr*nsnps)
# )
# annotatesnps <- d$SNP[7550:7750]
# manhattan plot using base graphics

manhattan = function(dataframe, colors=c("gray10", "gray50"), ymax="max", ymin=0, cex.x.axis=1, limitchromosomes=1:23, suggestiveline=-log10(1e-5), genomewideline=-log10(5e-8), annotate=NULL, ...) {
d=dataframe
if (!("CHR" %in% names(d) & "BP" %in% names(d) & "P" %in% names(d))) stop("Make sure your data frame contains columns CHR, BP, and P")
if (any(limitchromosomes)) d=d[d$CHR %in% limitchromosomes, ]
d=subset(na.omit(d[order(d$CHR, d$BP), ]), (P>0 & P<=1)) # remove na's, sort, and keep only 0<P<=1
d$logp = -log10(d$P)
d$pos=NA
ticks=NULL
lastbase=0
colors <- rep(colors,max(d$CHR))[1:max(d$CHR)]
if (ymax=="max") ymax<-ceiling(max(d$logp))
#if (ymax<8) ymax<-8
numchroms=length(unique(d$CHR))
if (numchroms==1) {
d$pos=d$BP
ticks=floor(length(d$pos))/2+1
} else {
for (i in unique(d$CHR)) {
if (i==1) {
d[d$CHR==i, ]$pos=d[d$CHR==i, ]$BP
} else {
lastbase=lastbase+tail(subset(d,CHR==i-1)$BP, 1)
d[d$CHR==i, ]$pos=d[d$CHR==i, ]$BP+lastbase
}
ticks=c(ticks, d[d$CHR==i, ]$pos[floor(length(d[d$CHR==i, ]$pos)/2)+1])
}
}
if (numchroms==1) {
with(d, plot(pos, logp, ylim=c(ymin,ymax), ylab=expression(-log[10](italic(p))), xlab=paste("Chromosome",unique(d$CHR),"position"), ...))
} else {
with(d, plot(pos, logp, ylim=c(ymin,ymax), ylab=expression(-log[10](italic(p))), xlab="Chromosome", xaxt="n", type="n", ...))
axis(1, at=ticks, lab=unique(d$CHR), cex.axis=cex.x.axis)
icol=1
for (i in unique(d$CHR)) {
with(d[d$CHR==i, ],points(pos, logp, col=colors[icol], ...))
icol=icol+1
}
}
if (!is.null(annotate)) {
d.annotate=d[which(d$SNP %in% annotate), ]
with(d.annotate, points(pos, logp, col="green3", ...)) 
}
if (suggestiveline) abline(h=suggestiveline, col="blue")
if (genomewideline) abline(h=genomewideline, col="red")
}

# Base graphics qq plot
qq = function(pvector, ...) {
if (!is.numeric(pvector)) stop("D'oh! P value vector is not numeric.")
pvector <- pvector[!is.na(pvector) & pvector<1 & pvector>0]
o = -log10(sort(pvector,decreasing=F))
#e = -log10( 1:length(o)/length(o) )
e = -log10( ppoints(length(pvector) ))
plot(e,o,pch=19,cex=1, xlab=expression(Expected~~-log[10](italic(p))), ylab=expression(Observed~~-log[10](italic(p))), xlim=c(0,max(e)), ylim=c(0,max(o)), ...)
abline(0,1,col="red")
}


# manhattanLOD plots Test Statistic (e.g. LOD) rather than -log10P
# Note manhattanLOD function assumes cols named SNP, CHR, BP, LOD
# Can change y axis label by using: myylab="mylabel"
# Default label is LOD


manhattanLOD = function(dataframe, colors=c("gray10", "gray50"), ymax="max", ymin=0, myylab="LOD", 
cex.x.axis=1, limitchromosomes=1:23, suggestiveline=-log10(1e-5), genomewideline=-log10(5e-8), annotate=NULL, ...) {
d=dataframe
if (!("CHR" %in% names(d) & "BP" %in% names(d) & "LOD" %in% names(d))) stop("Make sure your data frame contains columns CHR, BP, and LOD")
if (any(limitchromosomes)) d=d[d$CHR %in% limitchromosomes, ]
d=subset(na.omit(d[order(d$CHR, d$BP), ]), (LOD>-1000 & LOD<=1000)) # remove na's, sort, and keep only -1000<LOD<=1000
d$logp = d$LOD
d$pos=NA
ticks=NULL
lastbase=0
colors <- rep(colors,max(d$CHR))[1:max(d$CHR)]
if (ymax=="max") ymax<-ceiling(max(d$logp))
#if (ymax<8) ymax<-8
numchroms=length(unique(d$CHR))
if (numchroms==1) {
d$pos=d$BP
ticks=floor(length(d$pos))/2+1
} else {
for (i in unique(d$CHR)) {
if (i==1) {
d[d$CHR==i, ]$pos=d[d$CHR==i, ]$BP
} else {
lastbase=lastbase+tail(subset(d,CHR==i-1)$BP, 1)
d[d$CHR==i, ]$pos=d[d$CHR==i, ]$BP+lastbase
}
ticks=c(ticks, d[d$CHR==i, ]$pos[floor(length(d[d$CHR==i, ]$pos)/2)+1])
}
}
if (numchroms==1) {
with(d, plot(pos, logp, ylim=c(ymin,ymax), ylab=myylab, xlab=paste("Chromosome",unique(d$CHR),"position"), ...))
} else {
with(d, plot(pos, logp, ylim=c(ymin,ymax), ylab=myylab, xlab="Chromosome", xaxt="n", type="n", ...))
axis(1, at=ticks, lab=unique(d$CHR), cex.axis=cex.x.axis)
icol=1
for (i in unique(d$CHR)) {
with(d[d$CHR==i, ],points(pos, logp, col=colors[icol], ...))
icol=icol+1
}
}
if (!is.null(annotate)) {
d.annotate=d[which(d$SNP %in% annotate), ]
with(d.annotate, points(pos, logp, col="green3", ...)) 
}
if (suggestiveline) abline(h=suggestiveline, col="blue")
if (genomewideline) abline(h=genomewideline, col="red")
}







manhattanLOD2 = function(dataframe, colors=c("gray10", "gray50"), ymax="max", ymin=0, myylab="LOD", myxlab="Chromosome",
cex.x.axis=1, limitchromosomes=1:23, suggestiveline=-log10(1e-5), genomewideline=-log10(5e-8), annotate=NULL, ...) {
d=dataframe
if (!("CHR" %in% names(d) & "BP" %in% names(d) & "LOD" %in% names(d))) stop("Make sure your data frame contains columns CHR, BP, and LOD")
if (any(limitchromosomes)) d=d[d$CHR %in% limitchromosomes, ]
d=subset(na.omit(d[order(d$CHR, d$BP), ]), (LOD>-1000 & LOD<=1000)) # remove na's, sort, and keep only -1000<LOD<=1000
d$logp = d$LOD
d$pos=NA
ticks=NULL
lastbase=0
colors <- rep(colors,max(d$CHR))[1:max(d$CHR)]
if (ymax=="max") ymax<-ceiling(max(d$logp))
#if (ymax<8) ymax<-8
numchroms=length(unique(d$CHR))
if (numchroms==1) {
d$pos=d$BP
ticks=floor(length(d$pos))/2+1
} else {
for (i in unique(d$CHR)) {
if (i==1) {
d[d$CHR==i, ]$pos=d[d$CHR==i, ]$BP
} else {
lastbase=lastbase+tail(subset(d,CHR==i-1)$BP, 1)
d[d$CHR==i, ]$pos=d[d$CHR==i, ]$BP+lastbase
}
ticks=c(ticks, d[d$CHR==i, ]$pos[floor(length(d[d$CHR==i, ]$pos)/2)+1])
}
}
if (numchroms==1) {
with(d, plot(pos, logp, ylim=c(ymin,ymax), ylab=myylab, xlab=paste("Chromosome",unique(d$CHR),"position"), ...))
} else {
with(d, plot(pos, logp, ylim=c(ymin,ymax), ylab=myylab, xlab=myxlab, xaxt="n", type="n", ...))
axis(1, at=ticks, lab=unique(d$CHR), cex.axis=cex.x.axis)
icol=1
for (i in unique(d$CHR)) {
with(d[d$CHR==i, ],points(pos, logp, col=colors[icol], ...))
icol=icol+1
}
}
if (!is.null(annotate)) {
d.annotate=d[which(d$SNP %in% annotate), ]
with(d.annotate, points(pos, logp, col="green3", ...))
}
if (suggestiveline) abline(h=suggestiveline, col="blue")
if (genomewideline) abline(h=genomewideline, col="red")
}

