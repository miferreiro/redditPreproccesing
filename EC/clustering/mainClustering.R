source("src/pkgChecker.R")
source("src/read_csv.R")

##################################################################
##                          CLUSTERING                          ##
##################################################################

message(green("[Clustering][INFO] Starting clustering"))

source("distance.R")
source("visualizationDistance.R")
source("kmeans.R")
source("hierarchalClustering.R")

message(green("[Clustering][INFO] Finish clustering!"))