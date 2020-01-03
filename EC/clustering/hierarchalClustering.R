source("src/pkgChecker.R")
source("src/read_csv.R")

#################################################################
##                    Hierarchal Clustering                    ##
#################################################################

dtm <- readRDS("files_input/out_dtm_IG.rds")
# dtm <- readRDS("files_input/out_dtm_tfidf_IG.rds")

dist <- readRDS("files_output/out_dist_euclidian.rds")
# dist <- readRDS("files_output/out_tfidf_dist_euclidian.rds")

set.seed(123)
fit <- hclust(d = dist, method = "ward.D2")
factoextra::fviz_dend(fit, cex = 0.5, k = 4, palette = "jco")

pheatmap::pheatmap(t(dtm), cutree_cols = 4)


# plot(fit, hang = -1)
#
# groups <- cutree(fit, k = 10)
# rect.hclust(fit, k = 10, border = "red")
#
#
#
# fit <- pvclust(dtm, method.hclust="ward",
#                method.dist="euclidean")
# plot(fit)
# pvrect(fit, alpha=.95)
#
# # Model Based Clustering
# library(mclust)
# fit <- Mclust(dtm)
# saveRDS(fit, "files_output/out_model_based_clustering_mclust.rds")
# plot(fit) # plot results
# summary(fit) # display the best model
