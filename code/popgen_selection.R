#############################################################
### Michael Nothnagel, michael.nothnagel@uni-koeln.de     ###
### Calculation allele frequency changes due to selection ###
#############################################################


s.s   = c(0.001, 0.01, 0.1)
h     = 0.5
n.gen = 100

# === Calculate allele frequency changes === #
for (s in s.s) {
  freqs = rep(NA, n.gen+1)
  af = 0.5
  freqs[1] = 1-af
  for (j in 1:n.gen) {
    omega = 1 - 2*af*(1-af)*h*s - (1-af)*(1-af)*s
    f.het = (1-h*s)*2*af*(1-af)/omega
    f.hom = af*af/omega
    af = f.hom + f.het/2
    freqs[j+1] = 1-af
   }
  assign (paste("freqs.s", s, sep=""), freqs)
 }

# === Report allele frequencies after 100 generations === #
for (s in s.s) {
  cat("s=") ;  cat(s) ;  cat(":  ")
  freqs = get(paste("freqs.s", s, sep=""))
  cat(freqs[n.gen+1]) ;  cat("\n")
 }

# === Graph allele frequency changes === #
pdf("selection_plot.pdf", paper="special", height=4*2, width=4*2, onefile=F)
  plot(x=0, y=0, type="n", xlim=c(0,n.gen), ylim=c(0,1), xlab="Generation", ylab="Allele frequency")
    lines (c(0,n.gen), rep(0.5, 2), lty=3, col="#AAAAAA")
    for (s in s.s) {
      freqs = get(paste("freqs.s", s, sep=""))
      lines(0:n.gen,freqs, col="#44AAAA")
     }
dev.off()

#############################################################
#############################################################
