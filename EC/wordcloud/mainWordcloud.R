source("src/pkgChecker.R")
source("src/read_csv.R")

#################################################################
##                          WORDCLOUD                          ##
#################################################################

message(green("[Wordcloud][INFO] Starting plotting wordclouds using wordcloud package..."))

csv <- read_csv(csv = "files_input/outPre_all_comments_september.csv")
dtm <- readRDS("files_input/out_final_dtm_tm.rds")
# dtm <- readRDS("files_input/out_final_dtm_tfidf_tm.rds")

for (subreddit in unique(csv$subreddit)) {
  message(blue("[Wordcloud][INFO] Plotting", subreddit, "wordcloud"))

  freq <- colSums(as.matrix(dtm[csv$subreddit == subreddit, findFreqTerms(dtm, lowfreq = 1000) ]))
  freq <- sort(freq,
               decreasing = TRUE)

  pdf(paste0("files_output/", subreddit, "_dtm_wordcloud.pdf"))
  # pdf(paste0("files_output/", subreddit, "_dtm_tfidf_wordcloud.pdf"))
  plot <- wordcloud::wordcloud(names(freq),
                               freq,
                               max.words = 50,
                               scale = c(4, .2),
                               colors = RColorBrewer::brewer.pal(8, "Dark2"))
  dev.off()
  rm(freq)
}

message(green("[Wordcloud][INFO] Finish plotting wordclouds using wordcloud package..."))
