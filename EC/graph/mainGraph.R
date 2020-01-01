source("src/pkgChecker.R")
#https://kateto.net/networks-r-igraph
#https://www.jessesadler.com/post/network-analysis-with-r/
#################################################################
##                            GRAPH                            ##
#################################################################

message(green("[Graph][INFO] Starting creating graph using igraph package..."))

dtm <- readRDS("files_input/out_dtm_IG.rds")
# dtm <- readRDS("files_input/out_dtm_tfidf_IG.rds")

matrix <- as.matrix(dtm)
# matrix[matrix >= 1] <- 1
termMatrix <- t(matrix) %*% matrix

saveRDS(termMatrix, "files_output/termMatrix.rds")
termMatrix <- readRDS("files_output/termMatrix.rds")

g <- igraph::graph.adjacency(termMatrix, weighted = T, mode = "directed")

# plot(g, edge.color = "orange", vertex.color = "gray50")
plot(g, layout = layout_with_graphopt, edge.arrow.size = 0.2)

rglplot(g)



deg.dist <- degree_distribution(g, cumulative = T, mode = "all")

plot( x = 0:max(deg), y = 1-deg.dist, pch = 19, cex = 1.2, col = "orange",

      xlab = "Degree", ylab = "Cumulative Frequency")


kc <- coreness(g, mode = "all")
colrs <- adjustcolor( c("gray50", "tomato", "gold", "yellowgreen"), alpha = .6)
plot(g, vertex.size = kc*6, vertex.label = kc, vertex.color = colrs[kc])

message(green("[Graph][INFO] Finish creating graph using igraph package!"))
