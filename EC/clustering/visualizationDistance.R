source("src/pkgChecker.R")

##################################################################
##                    VISUALIZATION DISTANCE                    ##
##################################################################

message(green("[Clustering][INFO] Starting visualization distance."))

diste <- readRDS("files_output/out_dist_euclidian.rds")
distet <- readRDS("files_output/out_tfidf_dist_euclidian.rds")

distp <- readRDS("files_output/out_dist_pearson.rds")
distpt <- readRDS("files_output/out_tfidf_dist_pearson.rds")

pdf(paste0("files_output/out_dist_euclidian_heatmap.pdf"))
factoextra::fviz_dist(diste, show_labels = FALSE)
dev.off()

pdf(paste0("files_output/out_tfidf_dist_euclidian_heatmap.pdf"))
factoextra::fviz_dist(distet, show_labels = FALSE)
dev.off()

pdf(paste0("files_output/out_dist_pearson_heatmap.pdf"))
factoextra::fviz_dist(distp, show_labels = FALSE)
dev.off()

pdf(paste0("files_output/out_tfidf_dist_pearson_heatmap.pdf"))
factoextra::fviz_dist(distpt, show_labels = FALSE)
dev.off()
