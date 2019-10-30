#############################################################
### Michael Nothnagel, michael.nothnagel@uni-koeln.de     ###
### Simulating genetic drift                              ###
#############################################################


N.s   = c(10, 100, 1000, 10000)
n.gen =  50
n.rep = 100

# === Simulate genetic drift === #
for (n in N.s) {
  freqs = matrix(NA, ncol=n.gen+1, nrow=n.rep)
  for (i in 1:n.rep) {
    alleles = c(rep(0,n/2), rep(1,n/2))
    freqs[i,1] = sum(alleles==1) / length(alleles)
    for (j in 1:n.gen) {
      alleles = sample (alleles, length(alleles), replace=T)
      freqs[i,j+1] = sum(alleles==1) / length(alleles)
     }
   }
  assign (paste("freqs.n", n, sep=""), freqs)
 }

summary(freqs.n10   [,n.gen+1])
summary(freqs.n100  [,n.gen+1])
summary(freqs.n1000 [,n.gen+1])
summary(freqs.n10000[,n.gen+1])

# === Graph allele frequency changes === #
pdf("drift_plot.pdf", paper="special", height=4*2, width=4*2, onefile=F)
  split.screen(c(2,2))
    screen(1)
      plot(x=0, y=0, type="n", xlim=c(0,n.gen), ylim=c(0,1), xlab="Generation", ylab="Allele frequency", main="N=10")
        lines (c(0,n.gen), rep(0.5, 2), lty=3, col="#AAAAAA")
        freqs = get(paste("freqs.n", 10   , sep=""))
        for (i in 1:n.rep) {
          lines(0:n.gen,freqs[i,], col="#44AAAA")
         }
    screen(2)
      plot(x=0, y=0, type="n", xlim=c(0,n.gen), ylim=c(0,1), xlab="Generation", ylab="Allele frequency", main="N=100")
        lines (c(0,n.gen), rep(0.5, 2), lty=3, col="#AAAAAA")
        freqs = get(paste("freqs.n", 100  , sep=""))
        for (i in 1:n.rep) {
          lines(0:n.gen,freqs[i,], col="#44AAAA")
         }
    screen(3)
      plot(x=0, y=0, type="n", xlim=c(0,n.gen), ylim=c(0,1), xlab="Generation", ylab="Allele frequency", main="N=1000")
        lines (c(0,n.gen), rep(0.5, 2), lty=3, col="#AAAAAA")
        freqs = get(paste("freqs.n", 1000 , sep=""))
        for (i in 1:n.rep) {
          lines(0:n.gen,freqs[i,], col="#44AAAA")
         }
    screen(4)
      plot(x=0, y=0, type="n", xlim=c(0,n.gen), ylim=c(0,1), xlab="Generation", ylab="Allele frequency", main="N=10000")
        lines (c(0,n.gen), rep(0.5, 2), lty=3, col="#AAAAAA")
        freqs = get(paste("freqs.n", 10000, sep=""))
        for (i in 1:n.rep) {
          lines(0:n.gen,freqs[i,], col="#44AAAA")
         }
  close.screen(all.screens=T)
dev.off()

# === Graph allele frequency after 50 generations === #
pdf("drift_hist.pdf", paper="special", height=4*2, width=4*2, onefile=F)
  split.screen(c(2,2))
    screen(1)
      hist(freqs.n10   [,n.gen+1], main="N=10", xlab="Allele frequency", xlim=c(0,1))
    screen(2)
      hist(freqs.n100  [,n.gen+1], main="N=100", xlab="Allele frequency", xlim=c(0,1))
    screen(3)
      hist(freqs.n1000 [,n.gen+1], main="N=1000", xlab="Allele frequency", xlim=c(0,1))
    screen(4)
      hist(freqs.n10000[,n.gen+1], main="N=10000", xlab="Allele frequency", xlim=c(0,1))
  close.screen(all.screens=T)
dev.off()


#############################################################
###########################################################