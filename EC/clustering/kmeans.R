source("src/pkgChecker.R")

##################################################################
##                      K-means clustering                      ##
##################################################################

dtm <- readRDS("files_input/out_dtm_IG.rds")
# dtm <- readRDS("files_input/out_dtm_tfidf_IG.rds")

dist <- readRDS("files_output/out_dist_euclidian.rds")
# dist <- readRDS("files_output/out_tfidf_dist_euclidian.rds")

factoextra::fviz_nbclust(dtm, kmeans, method = "silhouette")

set.seed(123)
kfit <- kmeans(dist, 10)#,nstart = 25 )

factoextra::fviz_cluster(kfit, data = dtm, palette = "jco", repel = TRUE,
                         ggtheme = theme_minimal())

aggregate(dtm, by=list(cluster=kfit$cluster), mean)

# clusplot(as.matrix(d), kfit$cluster, color = T, shade = T, labels = 10, lines = 0)
#
# library(fpc)
# plotcluster(dtm, fit$cluster)
#
# # comparing 2 cluster solutions
# library(fpc)
# cluster.stats(d, fit1$cluster, fit2$cluster)