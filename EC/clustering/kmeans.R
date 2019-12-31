source("src/pkgChecker.R")
source("src/read_csv.R")

##################################################################
##                      K-means clustering                      ##
##################################################################

dtm <- readRDS("files_input/out_dtm_IG.rds")
# dtm <- readRDS("files_input/out_dtm_tfidf_IG.rds")

d <- readRDS("files_output/out_dist_euclidian.rds")
# d <- readRDS("files_output/out_tfidf_dist_euclidian.rds")

kfit <- kmeans(d, 10)

clusplot(as.matrix(d), kfit$cluster, color = T, shade = T, labels = 10, lines = 0)

library(fpc)
plotcluster(dtm, fit$cluster)

# comparing 2 cluster solutions
library(fpc)
cluster.stats(d, fit1$cluster, fit2$cluster)