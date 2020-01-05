source("src/pkgChecker.R")

diste <- readRDS("files_output/out_dist_euclidian.rds")
distet <- readRDS("files_output/out_tfidf_dist_euclidian.rds")

distp <- readRDS("files_output/out_dist_pearson.rds")
distpt <- readRDS("files_output/out_tfidf_dist_pearson.rds")

#################################################################
##                  Hierarchical Clustering                    ##
#################################################################


# set.seed(123)
# fit <- hclust(d = dist, method = "average")
# cor(dist, cophenetic(fit))
# factoextra::fviz_dend(fit, cex = 0.2, k = 10, color_labels_by_k = TRUE,  palette = "jco")
#


cfitEu <- hcut(x = diste, k = 4, hc_method = "ward.D", hc_metric = "euclidean")
pdf(paste0("files_output/out_dist_euclidian_hierarClus.pdf"))
factoextra::fviz_dend(cfitEu, k = 4, rect = TRUE, cex = 0.5,  pallete = "jco")
dev.off()

cfitEuTf <- hcut(x = distet, k = 4, hc_method = "ward.D", hc_metric = "euclidean")
pdf(paste0("files_output/out_tfidf_dist_euclidian_hierarClus.pdf"))
factoextra::fviz_dend(cfitEuTf, k = 4, rect = TRUE, cex = 0.5,  pallete = "jco")
dev.off()

cfitPe <- hcut(x = distp, k = 4, hc_method = "ward.D", hc_metric = "pearson")
pdf(paste0("files_output/out_dist_pearson_hierarClus.pdf"))
factoextra::fviz_dend(cfitPe, k = 4, rect = TRUE, cex = 0.5, pallete = "jco")
dev.off()

cfitPeTf <- hcut(x = distpt, k = 4, hc_method = "ward.D", hc_metric = "pearson")
pdf(paste0("files_output/out_tfidf_dist_pearson_hierarClus.pdf"))
factoextra::fviz_dend(cfitPeTf, k = 4, rect = TRUE, cex = 0.5, pallete = "jco")
dev.off()

table(cfitEu$cluster)
table(cfitEuTf$cluster)
table(cfitPe$cluster)
table(cfitPeTf$cluster)

scfitEu <- fpc::cluster.stats(d = diste, cfitEu$cluster)
scfitEuTf <- fpc::cluster.stats(d = distet, cfitEuTf$cluster)
scfitPe <- fpc::cluster.stats(d = distp, cfitPe$cluster)
scfitPeTf <- fpc::cluster.stats(d = distpt, cfitPeTf$cluster)

scfitEu$dunn
scfitEu$clus.avg.silwidths
scfitEuTf$dunn
scfitEuTf$clus.avg.silwidths
scfitPe$dunn
scfitPe$clus.avg.silwidths
scfitPeTf$dunn
scfitPeTf$clus.avg.silwidths

