source("src/pkgChecker.R")
source("src/read_csv.R")

#################################################################
##                          WORDCLOUD                          ##
#################################################################

message(green("[Wordcloud][INFO] Starting plotting wordclouds using wordcloud package..."))

csv <- read_csv(csv = "files_input/outPre_all_comments_september.csv")
target <- csv$subreddit
rm(csv)


for (subreddit in unique(target)) {
  message(blue("[Wordcloud][INFO] Plotting", subreddit, "wordcloud"))

  # dtm <- readRDS("files_input/out_final_dtm_tm.rds")
  dtm <- readRDS("files_input/out_final_dtm_tfidf_tm.rds")

  d <- dtm[target == subreddit, ]
  rm(dtm)
  m <- as.matrix(d[,findFreqTerms(d, 10)])
  freq <- colSums(m)
  freq <- sort(freq,
               decreasing = TRUE)

  # pdf(paste0("files_output/", subreddit, "_dtm_tm_wordcloud.pdf"))
  pdf(paste0("files_output/", subreddit, "_dtm_tfidf_tm_wordcloud.pdf"))
  plot <- wordcloud::wordcloud(names(freq),
                               freq,
                               max.words = 50,
                               scale = c(4, .2),
                               colors = RColorBrewer::brewer.pal(8, "Dark2"))
  dev.off()
  rm(freq)
  rm(plot)
}

message(green("[Wordcloud][INFO] Finish plotting wordclouds using wordcloud package..."))
