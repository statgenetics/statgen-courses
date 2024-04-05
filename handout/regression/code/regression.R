
# Data set import

load("dbp.R")
ls()
dbp[1:5,]


# I. Logistic regression on a single SNP genotype

result.snp12 = glm (affection ~ rs1112, family=binomial("logit"), data=dbp)
print (result.snp12)
print ( class  (result.snp12) )
print ( summary(result.snp12) )

dev.geno = anova (result.snp12, test="Chi")
lrt.pvalue = pchisq(dev.geno[dim(dev.geno)[1],"Deviance"], 
             df=2, ncp=0, FALSE) 
print ( lrt.pvalue )

print ( summary(result.snp12)$coefficients )
snp.beta = summary(result.snp12)$coefficients[2:3,1]
print ( snp.beta )
print ( exp(snp.beta) )

ci = confint (result.snp12)
print (ci) 
print ( exp(ci) )

snp.data = dbp[,c("affection", "rs1112")]
summary(snp.data)

snp.data[,"rs1112"] <- as.numeric(snp.data[,"rs1112"]) - 1
summary(snp.data)

result.all = glm (affection ~ rs1112, family=binomial("logit"), 
                  data=snp.data)
dev.all    = anova (result.all, test="Chi")
summary(result.all)   
print(dev.all) 


# II. Adjustment for the effects of covariates and of other SNPs

snp.data = dbp[,c("affection", "trait","sex", "age", "rs1112", "rs1117")]
summary(snp.data)

snp.data[,"rs1112"] <- as.numeric(snp.data[,"rs1112"]) - 1
snp.data[,"rs1117"] <- as.numeric(snp.data[,"rs1117"]) - 1

result.adj = glm (affection ~ sex + rs1112      , family=binomial("logit"), 
                  data=snp.data)
summary(result.adj)

result.adj = glm (affection ~ age + rs1112      , family=binomial("logit"), 
                  data=snp.data)
summary(result.adj)

result.adj = glm (affection ~ sex + age + rs1112, family=binomial("logit"), 
                  data=snp.data)
summary(result.adj)

result.adj = glm (affection ~ rs1117 + rs1112, family=binomial("logit"), 
                  data=snp.data)
summary(result.adj)
anova (result.adj, test="Chi")

result.adj = glm (affection ~ rs1112 + rs1117, family=binomial("logit"), 
                  data=snp.data)
summary(result.adj)
anova (result.adj, test="Chi")


# III. Analysis of quantitative instead of dichotomized trait

result.adj = lm (trait ~ rs1112      , data=snp.data)
summary(result.adj)

result.adj = lm (trait ~ sex + rs1112, data=snp.data)
summary(result.adj)
 
 
# IV. Gene-environment (GxE) and gene-gene (GxG) interaction

result.inter = glm (affection ~ sex * rs1112, family=binomial("logit"), 
                    data=snp.data)
summary(result.inter)

result.inter = glm (affection ~ age * rs1112, family=binomial("logit"), 
                    data=snp.data)
summary(result.inter)

result.inter = glm (affection ~ rs1112 * rs1117, family=binomial("logit"), 
                    data=snp.data)
summary(result.inter)


# Quitting 
q()


