
n.ca = c(159, 122,  19)
n.co = c(120, 139,  41)

 sum.co = sum(n.co)

 n.co/sum.co

 co.A = (2*n.co[1] + n.co[2]) / 2 / sum.co
 co.B = (2*n.co[3] + n.co[2]) / 2 / sum.co
   co.A ;  co.B
 
 sum.co *     co.A * co.A
 sum.co * 2 * co.A * co.B
 sum.co *     co.B * co.B
 

  (n.co/sum.co)[1]

  ((n.co/sum.co)[1] - co.A*co.A) / (co.A - co.A*co.A)

### END OF FILE #############

