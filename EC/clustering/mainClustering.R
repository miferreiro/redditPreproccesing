source("src/pkgChecker.R")
source("src/read_csv.R")

##################################################################
##                          CLUSTERING                          ##
##################################################################

message(green("[Clustering][INFO] Starting clustering"))

# dtm <- readRDS("files_input/out_dtm_IG.rds")
dtm <- readRDS("files_input/out_dtm_tfidf_IG.rds")


data.frame.dtm <- readRDS("data_frame_dtm_final.rds")
# distance <- factoextra::get_dist(data.frame.dtm)
# factoextra::fviz_dist(distance, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))

k2 <- stats::kmeans(data.frame.dtm, centers = 12, iter.max = 10, nstart = 1, trace = TRUE)
str(k2)
plot(data.frame.dtm, col = k2$cluster)

#https://rstudio-pubs-static.s3.amazonaws.com/265713_cbef910aee7642dc8b62996e38d2825d.html


message(green("[Clustering][INFO] Finish clustering!"))