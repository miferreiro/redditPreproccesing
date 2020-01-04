source("src/pkgChecker.R")

#################################################################
##                          FREQUENCY                          ##
#################################################################

message(green("[Clustering][INFO] Starting frequency"))

dtm <- readRDS("files_input/out_dtm_IG.rds")
# dtm <- readRDS("files_input/out_dtm_tfidf_IG.rds")

freq <- sort(colSums(as.matrix(dtm)),
             decreasing = TRUE)

wf <- data.frame(word = names(freq),
                 freq = freq)
grDevices::pdf("files_output/dtm_IG_frequency.pdf")
# grDevices::pdf("files_output/dtm_tfidf_IG_frequency.pdf")
plot <- ggplot2::ggplot(subset(wf, freq > 2500), aes(x = reorder(word, -freq), y = freq)) +
                        geom_bar(stat = "identity") +
                        theme(axis.text.x = element_text( angle = 45, hjust = 1))
dev.off()