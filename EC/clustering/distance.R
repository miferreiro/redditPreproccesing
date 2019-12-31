source("src/pkgChecker.R")
source("src/read_csv.R")

##################################################################
##                           DISTANCE                           ##
##################################################################

message(green("[Clustering][INFO] Starting calculating distance."))

dtm <- readRDS("files_input/out_dtm_IG.rds")
# dtm <- readRDS("files_input/out_dtm_tfidf_IG.rds")


d <- dist(t(dtm), method = "euclidian")
saveRDS(d, "files_output/out_dist_euclidian.rds")
# saveRDS(d, "files_output/out_tfidf_dist_euclidian.rds")