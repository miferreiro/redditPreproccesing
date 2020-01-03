source("src/pkgChecker.R")
source("src/read_csv.R")

##################################################################
##                    VISUALIZATION DISTANCE                    ##
##################################################################

message(green("[Clustering][INFO] Starting visualization distance."))

dist <- readRDS("files_output/out_dist_euclidian.rds")
# dist <- readRDS("files_output/out_tfidf_dist_euclidian.rds")

pdf(paste0("files_output/out_dist_euclidian_heatmap.pdf"))
# pdf(paste0("files_output/out_tfidf_dist_euclidian_heatmap.pdf"))
factoextra::fviz_dist(dist)

dev.off()

