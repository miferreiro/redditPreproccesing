source("src/pkgChecker.R")
source("src/read_csv.R")

##################################################################
##                          CLUSTERING                          ##
##################################################################

message(green("[Clustering][INFO] Starting clustering"))

dtm <- readRDS("files_input/out_dtm_IG.rds")
# dtm <- readRDS("files_input/out_dtm_tfidf_IG.rds")

#################################################################
##                          FREQUENCY                          ##
#################################################################

# freq <- sort(colSums(as.matrix(dtm)),
#              decreasing = TRUE)
#
# wf <- data.frame(word = names(freq),
#                  freq = freq)
# # grDevices::pdf("files_output/dtm_IG_frequency.pdf")
# grDevices::pdf("files_output/dtm_tfidf_IG_frequency.pdf")
# plot <- ggplot2::ggplot(subset(wf, freq > 2500), aes(x = reorder(word, -freq), y = freq)) +
#                         geom_bar(stat = "identity") +
#                         theme(axis.text.x = element_text( angle = 45, hjust = 1))
# dev.off()


#################################################################
##                    Hierarchal Clustering                    ##
#################################################################

d <- dist(t(dtm), method = "euclidian")
fit <- hclust(d = d, method = "complete")
fit
plot(fit, hang = -1)

plot.new()
plot(fit, hang=-1)
groups <- cutree(fit, k=12)
rect.hclust(fit, k=12, border="red")
rm(d)
rm(fit)

##################################################################
##                      K-means clustering                      ##
##################################################################

d <- dist(t(dtm), method = "euclidian")
kfit <- kmeans(d, 10)
clusplot(as.matrix(d), kfit$cluster, color = T, shade = T, labels = 2, lines = 0)

################################################################################
################################################################################
################################################################################

data.frame.dtm <- readRDS("data_frame_dtm_final.rds")
# distance <- factoextra::get_dist(data.frame.dtm)
# factoextra::fviz_dist(distance, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))

k2 <- stats::kmeans(data.frame.dtm, centers = 12, iter.max = 10, nstart = 1, trace = TRUE)
str(k2)
plot(data.frame.dtm, col = k2$cluster)

#https://rstudio-pubs-static.s3.amazonaws.com/265713_cbef910aee7642dc8b62996e38d2825d.html


message(green("[Clustering][INFO] Finish clustering!"))