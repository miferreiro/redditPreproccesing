source("src/pkgChecker.R")

##################################################################
##                           DISTANCE                           ##
##################################################################

message(green("[Clustering][INFO] Starting calculating distance."))

dtm <- readRDS("files_input/out_dtm_IG.rds")
dist <- stats::dist(t(dtm), method = "euclidian")
saveRDS(dist, "files_output/out_dist_euclidian.rds")

dist <- factoextra::get_dist(t(dtm), method = "pearson")
saveRDS(dist, "files_output/out_dist_pearson.rds")

dtm <- readRDS("files_input/out_dtm_tfidf_IG.rds")
dist <- stats::dist(t(dtm), method = "euclidian")
saveRDS(dist, "files_output/out_tfidf_dist_euclidian.rds")

dist <- factoextra::get_dist(t(dtm), method = "pearson")
saveRDS(dist, "files_output/out_tfidf_dist_pearson.rds")