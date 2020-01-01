source("src/pkgChecker.R")
source("src/read_csv.R")

#################################################################
##                          WORDCLOUD                          ##
#################################################################

message(green("[Wordcloud][INFO] Starting plotting wordclouds using wordcloud package..."))

final.ig <- readRDS("files_input/out_IG.rds")
# final.ig <- readRDS("files_input/out_tfidf_IG.rds")

final.ig.n <- as.numeric(final.ig)
names(final.ig.n) <- names(final.ig)
final.ig <- final.ig.n

final.ig <- sort(final.ig, decreasing = T)

pdf("files_output/IG_wordcloud.pdf")
# pdf("files_output/tfidf_IG_wordcloud.pdf")
plot <- wordcloud::wordcloud(names(final.ig)[1:50],
                             final.ig[1:50],
                             max.words = 50,
                             scale = c(4, .2),
                             colors = RColorBrewer::brewer.pal(8, "Dark2"))
dev.off()

message(green("[Wordcloud][INFO] Finish plotting wordclouds using wordcloud package..."))
