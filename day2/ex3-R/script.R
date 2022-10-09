# Adapted from https://www.bioconductor.org/packages/devel/workflows/vignettes/RNAseq123/inst/doc/limmaWorkflow.html
# with lots of help from Hannah Coughlan

# Loading packages
library(limma)
library(edgeR)
library(Mus.musculus)
library(RColorBrewer)

# Data packaging and annotation
# The original example downloads directly from the internet, something that
# is forbidden in a Nix build to ensure reproducibility. Instead, we assume
# the tarball has already been fetched and unpacked, and the contents are
# available in the working directory
files <- c("GSM1545535_10_6_5_11.txt", "GSM1545536_9_6_5_11.txt", "GSM1545538_purep53.txt",
           "GSM1545539_JMS8-2.txt", "GSM1545540_JMS8-3.txt", "GSM1545541_JMS8-4.txt",
           "GSM1545542_JMS8-5.txt", "GSM1545544_JMS9-P7c.txt", "GSM1545545_JMS9-P8c.txt")
for(i in paste(files, ".gz", sep=""))
    R.utils::gunzip(i, overwrite=TRUE)

# Get the directory to output results in
out <- Sys.getenv("out")

## Create the DGEList-object
x <- readDGE(files, columns=c(1,3))

## Organising sample information
samplenames <- substring(colnames(x), 12, nchar(colnames(x)))

colnames(x) <- samplenames
group <- as.factor(c("LP", "ML", "Basal",
                     "Basal", "ML", "LP",
                     "Basal", "ML", "LP"))
x$samples$group <- group
lane <- as.factor(rep(c("L004","L006","L008"), c(3,4,2)))
x$samples$lane <- lane

## Gene annotation
geneid <- rownames(x)
genes <- select(Mus.musculus,
                keys=geneid,
                columns=c("SYMBOL", "TXCHROM"),
                keytype="ENTREZID")
head(genes)

# Filtering and normalisation

### Filtering for duplicated gene names
genes <- genes[!duplicated(genes$ENTREZID),]
x$genes <- genes

## Filtering for lowly expressed genes
keep.exprs <- filterByExpr(x, group=group)
x <- x[keep.exprs,, keep.lib.sizes=FALSE]
dim(x)

## Normalising gene expression distributions
x <- calcNormFactors(x, method = "TMM")

## Unsupervisd clustering if sampples
lcpm <- cpm(x, log=TRUE)

png(file=paste0(out, "/mds.png"),width=700, height=350)
par(mfrow=c(1,2))
col.group <- group
levels(col.group) <-  brewer.pal(nlevels(col.group), "Set1")
col.group <- as.character(col.group)
col.lane <- lane
levels(col.lane) <-  brewer.pal(nlevels(col.lane), "Set2")
col.lane <- as.character(col.lane)
plotMDS(lcpm, labels=group, col=col.group)
title(main="A. Sample groups")
plotMDS(lcpm, labels=lane, col=col.lane, dim=c(3,4))
title(main="B. Sequencing lanes")
dev.off()

# Differential expression analysis

## Creating a design matrix and contrasts
design <- model.matrix(~0+group+lane)
colnames(design) <- gsub("group", "", colnames(design))

contr.matrix <- makeContrasts(
    BasalvsLP = Basal-LP,
    BasalvsML = Basal - ML,
    LPvsML = LP - ML,
    levels = colnames(design))

## Removing heteroscedascity from count data
v <- voom(x, design, plot=FALSE)

vfit <- lmFit(v, design)
vfit <- contrasts.fit(vfit, contrasts=contr.matrix)
efit <- eBayes(vfit)

## Examining the number of DE genes
summary(decideTests(efit))

### Using treat
tfit <- treat(vfit, lfc=1)
dt <- decideTests(tfit)
summary(dt)

### List of DE genes
basal.vs.lp <- topTreat(tfit, coef=1, n=Inf)
head(basal.vs.lp)
write.csv(x = basal.vs.lp, file = paste0(out, "/DE_gene_list.csv"), quote = FALSE)

