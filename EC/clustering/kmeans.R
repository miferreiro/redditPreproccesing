source("src/pkgChecker.R")

diste <- readRDS("files_output/out_dist_euclidian.rds")
distet <- readRDS("files_output/out_tfidf_dist_euclidian.rds")

distp <- readRDS("files_output/out_dist_pearson.rds")
distpt <- readRDS("files_output/out_tfidf_dist_pearson.rds")

##################################################################
##                  OPTIMAL NUMBER OF CLUSTERS                  ##
##################################################################

# Elbow method
pdf(paste0("files_output/out_dist_euclidian_optimalNumCluster_elbow.pdf"))
factoextra::fviz_nbclust(as.matrix(diste), kmeans, method = "wss") +
  geom_vline(xintercept = 4, linetype = 2) +
  labs(subtitle = "Elbow method")
dev.off()

pdf(paste0("files_output/out_tfidf_dist_euclidian_optimalNumCluster_elbow.pdf"))
factoextra::fviz_nbclust(as.matrix(distet), kmeans, method = "wss") +
  geom_vline(xintercept = 4, linetype = 2) +
  labs(subtitle = "Elbow method")
dev.off()

pdf(paste0("files_output/out_dist_pearson_optimalNumCluster_elbow.pdf"))
factoextra::fviz_nbclust(as.matrix(distp), kmeans, method = "wss") +
  geom_vline(xintercept = 4, linetype = 2) +
  labs(subtitle = "Elbow method")
dev.off()

pdf(paste0("files_output/out_tfidf_dist_pearson_optimalNumCluster_elbow.pdf"))
factoextra::fviz_nbclust(as.matrix(distpt), kmeans, method = "wss") +
  geom_vline(xintercept = 4, linetype = 2) +
  labs(subtitle = "Elbow method")
dev.off()

# Silhouette method
pdf(paste0("files_output/out_dist_euclidian_optimalNumCluster_silhouette.pdf"))
factoextra::fviz_nbclust(as.matrix(diste), kmeans, method = "silhouette") +
  labs(subtitle = "Silhouette method")
dev.off()

pdf(paste0("files_output/out_tfidf_dist_euclidian_optimalNumCluster_silhouette.pdf"))
factoextra::fviz_nbclust(as.matrix(distet), kmeans, method = "silhouette") +
  labs(subtitle = "Silhouette method")
dev.off()

pdf(paste0("files_output/out_dist_pearson_optimalNumCluster_silhouette.pdf"))
factoextra::fviz_nbclust(as.matrix(distp), kmeans, method = "silhouette") +
  labs(subtitle = "Silhouette method")
dev.off()

pdf(paste0("files_output/out_tfidf_dist_pearson_optimalNumCluster_silhouette.pdf"))
factoextra::fviz_nbclust(as.matrix(distpt), kmeans, method = "silhouette") +
  labs(subtitle = "Silhouette method")
dev.off()

# Gap statistic
pdf(paste0("files_output/out_dist_euclidian_optimalNumCluster_gap_stat.pdf"))
factoextra::fviz_nbclust(as.matrix(diste), kmeans, method = "gap_stat", nboot = 50) +
  labs(subtitle = "Gap statistic method")
dev.off()

pdf(paste0("files_output/out_tfidf_dist_euclidian_optimalNumCluster_gap_stat.pdf"))
factoextra::fviz_nbclust(as.matrix(distet), kmeans, method = "gap_stat", nboot = 50) +
  labs(subtitle = "Gap statistic method")
dev.off()

pdf(paste0("files_output/out_dist_pearson_optimalNumCluster_gap_stat.pdf"))
factoextra::fviz_nbclust(as.matrix(distp), kmeans, method = "gap_stat", nboot = 50) +
  labs(subtitle = "Gap statistic method")
dev.off()

pdf(paste0("files_output/out_tfidf_dist_pearson_optimalNumCluster_gap_stat.pdf"))
factoextra::fviz_nbclust(as.matrix(distpt), kmeans, method = "gap_stat", nboot = 50) +
  labs(subtitle = "Gap statistic method")
dev.off()

##################################################################
##                      K-means clustering                      ##
##################################################################

set.seed(123)
kfitEu <- kmeans(diste, 4, nstart = 25)
pdf(paste0("files_output/out_dist_euclidian_kmeans4.pdf"))
factoextra::fviz_cluster(object = kfitEu, data = diste,
                         palette = "jco", geom = c("point"), main = "",
                         ggtheme = theme_minimal())
dev.off()

set.seed(123)
kfitEuTf <- kmeans(distet, 4, nstart = 25)
pdf(paste0("files_output/out_tfidf_dist_euclidian_kmeans4.pdf"))
factoextra::fviz_cluster(object = kfitEuTf, data = distet,
                         palette = "jco", geom = c("point"), main = "",
                         ggtheme = theme_minimal())
dev.off()

set.seed(123)
kfitPe <- kmeans(distp, 4, nstart = 25)
pdf(paste0("files_output/out_dist_pearson_kmeans4.pdf"))
factoextra::fviz_cluster(object = kfitPe, data = distp,
                         palette = "jco", geom = c("point"), main = "",
                         ggtheme = theme_minimal())
dev.off()

set.seed(123)
kfitPeTf <- kmeans(distpt, 4, nstart = 25)
pdf(paste0("files_output/out_tfidf_dist_pearson_kmeans4.pdf"))
factoextra::fviz_cluster(object = kfitPeTf, data = distpt,
                         palette = "jco", geom = c("point"), main = "",
                         ggtheme = theme_minimal())
dev.off()

table(kfitEu$cluster)
table(kfitEuTf$cluster)
table(kfitPe$cluster)
table(kfitPeTf$cluster)

skfitEu <- fpc::cluster.stats(d = diste, kfitEu$cluster)
skfitEuTf <- fpc::cluster.stats(d = distet, kfitEuTf$cluster)
skfitPe <- fpc::cluster.stats(d = distp, kfitPe$cluster)
skfitPeTf <- fpc::cluster.stats(d = distpt, kfitPeTf$cluster)

skfitEu$dunn
skfitEu$clus.avg.silwidths
skfitEuTf$dunn
skfitEuTf$clus.avg.silwidths
skfitPe$dunn
skfitPe$clus.avg.silwidths
skfitPeTf$dunn
skfitPeTf$clus.avg.silwidths
