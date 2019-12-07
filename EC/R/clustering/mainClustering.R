source("EC/R/clustering/pkgChecker.R");source("util/read_csv.R");source("EC/R/clustering/transformColumns.R")
csv <- read_csv(csv = "EC/R/clustering/files/outputPreprocesing.csv")
csv <- csv[1:(dim(csv)[1]/4),]
csv.corpus <- VCorpus(VectorSource(csv$data))

##################################################################
##                      BASIC PREPROCESING                      ##
##################################################################

message(green("[INFO] Applying tm_map..."))
csv.corpus <- tm_map(csv.corpus, stripWhitespace)
csv.corpus <- tm_map(csv.corpus, removeNumbers)
csv.corpus <- tm_map(csv.corpus, content_transformer(gsub), pattern = '[²!"“”„#$%&\'()*+,.\\/:;<=>?@\\\\^_\\{\\}|~\\[\\]‘’—-]+', replacement = ' ', perl = T)
removeLongWords <- content_transformer(function(x, length) {
  return(gsub(paste("(?:^|[[:space:]])[[:alnum:]]{", length, ",}(?=$|[[:space:]])", sep = ""), "", x, perl = T))
})
csv.corpus <- tm_map(csv.corpus, removeLongWords, 25)
csv.corpus <- tm_map(csv.corpus, removeWords, preposition)
csv.corpus <- tm_map(csv.corpus, removeWords, BuckleySaltonSWL)

##################################################################
##                         LEMATIZATION                         ##
##################################################################

# csv.corpus <- tm_map(csv.corpus, textstem::make_lemma_dictionary)
csv.corpus <- tm_map(csv.corpus, lemmatize_words)
csv.corpus <- tm_map(csv.corpus, PlainTextDocument)

#################################################################
##                         STEMIZATION                         ##
#################################################################

csv.corpus <- tm_map(csv.corpus, stemDocument, language = "english")

#################################################################
##                             DTM                             ##
#################################################################

message(green("[INFO] Transforming to DocumentTermMatrix..."))
dtm <- DocumentTermMatrix(csv.corpus)

##################################################################
##                   REMOVE MEANINGLESS WORDS                   ##
##################################################################

all_tokens <- findFreqTerms(dtm, 1)
tokens_to_remove <- setdiff(all_tokens, qdapDictionaries::DICTIONARY)

csv.corpus <- tm_map(csv.corpus, removeWords, tokens_to_remove[1:(length(tokens_to_remove)/4)])
csv.corpus <- tm_map(csv.corpus, removeWords, tokens_to_remove[(length(tokens_to_remove)/4):(length(tokens_to_remove)/2)])
csv.corpus <- tm_map(csv.corpus, removeWords, tokens_to_remove[(length(tokens_to_remove)/2):(length(tokens_to_remove)/4)*3])
csv.corpus <- tm_map(csv.corpus, removeWords, tokens_to_remove[(length(tokens_to_remove)/4)*3:(length(tokens_to_remove))])
rm(tokens_to_remove)

dtm <- DocumentTermMatrix(csv.corpus, control = list(weighting =
                                                       function(x)
                                                         weightTfIdf(x, normalize = FALSE)))

all_tokens <- findFreqTerms(dtm, 1)
tokens_to_remove <- setdiff(all_tokens, qdapDictionaries::BuckleySaltonSWL)

csv.corpus <- tm_map(csv.corpus, removeWords, tokens_to_remove[1:(length(tokens_to_remove)/4)])
csv.corpus <- tm_map(csv.corpus, removeWords, tokens_to_remove[(length(tokens_to_remove)/4):(length(tokens_to_remove)/2)])
csv.corpus <- tm_map(csv.corpus, removeWords, tokens_to_remove[(length(tokens_to_remove)/2):(length(tokens_to_remove)/4)*3])
csv.corpus <- tm_map(csv.corpus, removeWords, tokens_to_remove[(length(tokens_to_remove)/4)*3:(length(tokens_to_remove))])
rm(tokens_to_remove)
rm(all_tokens)

# dtm <- DocumentTermMatrix(csv.corpus, control = list(weighting =
#                                                        function(x)
#                                                          weightTfIdf(x, normalize = FALSE)))
dtm <- DocumentTermMatrix(csv.corpus)
# saveRDS(dtm, "EC/R/clustering/saveFilesRDS/dtm.RDS")

#################################################################
##                           END DTM                           ##
#################################################################
# dtm <- readRDS("EC/R/clustering/saveFilesRDS/dtm.RDS")
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

library(fpc)   
d <- dist(t(dtm), method = "euclidian")   
kfit <- kmeans(d, 10)   
clusplot(as.matrix(d), kfit$cluster, color = T, shade = T, labels = 2, lines = 0)  

#################################################################
##                     Normalizing columns                     ##
#################################################################

# dtm <- readRDS("EC/R/clustering/saveFilesRDS/dtm.RDS")
# rm(csv.corpus)
matrix.dtm <- as.matrix(dtm)
# rm(dtm)
data.frame.dtm <- as.data.frame(matrix.dtm)
names(data.frame.dtm)
# rm(matrix.dtm)

# message(green("[INFO] Normalizing columns..."))
# {
# data.frame.dtm$URLs <- csv$URLs
# data.frame.dtm$emoticon <- csv$emoticon
# data.frame.dtm$Emojis <- csv$Emojis
# data.frame.dtm$interjection <- csv$interjection
# data.frame.dtm$stopWord <- csv$stopWord
# data.frame.dtm$langpropname <- csv$langpropname
# 
# data.frame.dtm <- data.frame.dtm %>%
#   transformColums("URLs") %>%
#   transformColums("emoticon") %>%
#   transformColums("Emojis") %>%
#   transformColums("interjection") %>%
#   transformColums("stopWord") %>%
#   transformColums("langpropname")
# 
# }

# saveRDS(data.frame.dtm, "EC/R/clustering/saveFilesRDS/data-frame-dtm.RDS")

################################################################################
################################################################################
################################################################################
message(green("[INFO] Starting clustering"))

# distance <- factoextra::get_dist(data.frame.dtm)
# fviz_dist(distance, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))

# k2 <- kmeans(data.frame.dtm, centers = 10, iter.max = 1000, nstart = 25)
# str(k2)
# plot(data.frame.dtm, col = k2$cluster)

#https://rstudio-pubs-static.s3.amazonaws.com/265713_cbef910aee7642dc8b62996e38d2825d.html