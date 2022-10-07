library(edgeR)

# It's easier to read environment variables than parse command line arguments
counts <- read.delim(Sys.getenv("counts"), row.names=1)
out <- Sys.getenv("out")

group <- rep(c("A", "B"), each = 2)
design <- model.matrix(~group)
dge <- DGEList(counts=counts)
keep <- filterByExpr(dge, design)
dge <- dge[keep,,keep.lib.sizes=FALSE]
dge <- calcNormFactors(dge)
logCPM <- cpm(dge, log=TRUE, prior.count=3)
fit <- lmFit(logCPM, design)
fit <- eBayes(fit, trend=TRUE)
write.table(topTable(fit, coef=ncol(design)), file = out)
