source("src/pkgChecker.R")
source("src/read_csv.R");

message(green("[Clustering][INFO] Starting clustering"))

dtm <- readRDS("dtm_final.rds")

#################################################################
##                          FREQUENCY                          ##
#################################################################

freq <- sort(colSums(as.matrix(dtm)),
             decreasing = TRUE)

wf <- data.frame(word = names(freq),
                 freq = freq)

ggplot(subset(wf, freq > 200), aes(x = reorder(word, -freq), y = freq)) +
          geom_bar(stat = "identity") +
          theme(axis.text.x = element_text( angle = 45, hjust = 1))

wordcloud::wordcloud(names(freq),
                     freq,
                     min.freq = 200,
                     scale = c(5, .1),
                     colors = RColorBrewer::brewer.pal(6, "Dark2"))
rm(freq)
rm(wf)

#################################################################
##                    Hierarchal Clustering                    ##
#################################################################

d <- dist(t(dtm), method = "euclidian")
fit <- hclust(d = d, method = "complete")
fit
plot(fit, hang = -1)
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


# distance <- factoextra::get_dist(data.frame.dtm)
# fviz_dist(distance, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))

# k2 <- kmeans(data.frame.dtm, centers = 10, iter.max = 1000, nstart = 25)
# str(k2)
# plot(data.frame.dtm, col = k2$cluster)

#https://rstudio-pubs-static.s3.amazonaws.com/265713_cbef910aee7642dc8b62996e38d2825d.html


message(green("[Clustering][INFO] Finish clustering!"))