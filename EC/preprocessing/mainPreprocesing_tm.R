source("src/pkgChecker.R")
source("src/read_csv.R")
source("src/write_csv.R")

message(green("[Preprocesing][INFO] Starting preprocesing..."))

##################################################################
##                PREPROCESSING USING TM PACKAGE                ##
##################################################################
message(green("[Preprocesing][INFO] Starting preprocesing using tm package..."))
csv <- read_csv(csv = "files_input_tm/outPre_all_comments_september.csv")
csv.corpus <- VCorpus(VectorSource(csv$data))
##################################################################
##                      BASIC PREPROCESING                      ##
##################################################################
message(blue("[Preprocesing][INFO] Applying basic preprocesing..."))
csv.corpus <- tm_map(csv.corpus, stripWhitespace)
csv.corpus <- tm_map(csv.corpus, content_transformer(gsub), pattern = "^\\s+|\\s+$", replacement = "")
csv.corpus <- tm_map(csv.corpus, content_transformer(gsub), pattern = "\\p{Z}", replacement  = " ", perl = T)
csv.corpus <- tm_map(csv.corpus, content_transformer(trimws))
csv.corpus <- tm_map(csv.corpus, removeNumbers)
csv.corpus <- tm_map(csv.corpus, content_transformer(gsub), pattern = '[¿€¥±éÅ¾ž½…·µ×,‚£«»•²!"“”„#$%&\'`´()*+.\\/:;<=>?@\\\\^_\\{\\}|~\\[\\]‘’—–-]+', replacement = ' ', perl = T)
removeLongWords <- content_transformer(function(x, length) {
  return(gsub(paste("(?:^|[[:space:]])[[:alnum:]]{", length, ",}(?=$|[[:space:]])", sep = ""), "", x, perl = T))
})
csv.corpus <- tm_map(csv.corpus, removeLongWords, 17);rm(removeLongWords)#http://www.ravi.io/language-word-lengths
removeShortWords <- content_transformer(function(x, length) {
  return(gsub(paste("(?:^|[[:space:]])[[:alnum:]]{", length, "}(?=$|[[:space:]])", sep = ""), "", x, perl = T))
})
csv.corpus <- tm_map(csv.corpus, removeShortWords, 1)
csv.corpus <- tm_map(csv.corpus, removeShortWords, 2);rm(removeShortWords)
csv.corpus <- tm_map(csv.corpus, removeWords, qdapDictionaries::preposition)
csv.corpus <- tm_map(csv.corpus, removeWords, qdapDictionaries::BuckleySaltonSWL)
##################################################################
##                         LEMATIZATION                         ##
##################################################################
message(blue("[Preprocesing][INFO] Applying lematization..."))
csv.corpus <- tm_map(csv.corpus, textstem::lemmatize_words)
csv.corpus <- tm_map(csv.corpus, PlainTextDocument)
#################################################################
##                         STEMIZATION                         ##
#################################################################
message(blue("[Preprocesing][INFO] Applying stemization..."))
csv.corpus <- tm_map(csv.corpus, stemDocument, language = "english")
#################################################################
##                             DTM                             ##
#################################################################
message(blue("[Preprocesing][INFO] Transforming to dtm..."))
csv.corpus <- tm_map(csv.corpus, stripWhitespace)
csv.corpus <- tm_map(csv.corpus, content_transformer(gsub), pattern = "^\\s+|\\s+$", replacement  = "")
csv.corpus <- tm_map(csv.corpus, content_transformer(gsub), pattern = "\\p{Z}", replacement  = " ", perl = T)
csv.corpus <- tm_map(csv.corpus, content_transformer(trimws))
dtm <- DocumentTermMatrix(csv.corpus)
saveRDS(dtm, "files_output_tm/dtm_before_removeMeaningless.rds")
##################################################################
##                   REMOVE MEANINGLESS WORDS                   ##
##################################################################
message(blue("[Preprocesing][INFO] Taking most frequency terms..."))
all_tokens <- findFreqTerms(dtm, 1)
tokens_to_remove <- setdiff(findFreqTerms(dtm, 1), findFreqTerms(dtm, lowfreq = 1000))
c <- 1
while (c  < (length(tokens_to_remove))) {
  csv.corpus <- tm_map(csv.corpus, removeWords, tokens_to_remove[c:(c + 500)])
  c <- c + 500
  print(c)
}
rm(c)
csv.corpus <- tm_map(csv.corpus, stripWhitespace)
csv.corpus <- tm_map(csv.corpus, content_transformer(gsub), pattern = "^\\s+|\\s+$", replacement  = "")
csv.corpus <- tm_map(csv.corpus, content_transformer(gsub), pattern = "\\p{Z}", replacement  = " ", perl = T)
csv.corpus <- tm_map(csv.corpus, content_transformer(trimws))
dtm <- DocumentTermMatrix(csv.corpus)
# rm(csv.corpus)
saveRDS(dtm, "files_output_tm/dtm_final_1000.rds")
dtm <- readRDS("files_output_tm/dtm_final_1000.rds")
#################################################################
##                           END DTM                           ##
#################################################################
#################################################################
##                     Normalizing columns                     ##
#################################################################
matrix.dtm <- as.matrix(dtm)
rm(dtm)
matrix.dtm <- cbind(as.factor(csv$subreddit), matrix.dtm)
colnames(matrix.dtm)[1] <- "nameOfSubreddit"
data.frame.dtm <- as.data.frame(matrix.dtm)
rm(matrix.dtm)
message(blue("[Preprocesing][INFO] Dimension of final data frame: "), paste(dim(data.frame.dtm), collapse = " "))
message(blue("[Preprocesing][INFO] Normalizing columns..."))
{
  data.frame.dtm$URLs <- csv$URLs
  data.frame.dtm$emoticon <- csv$emoticon
  data.frame.dtm$Emojis <- csv$Emojis
  data.frame.dtm$interjection <- csv$interjection
  data.frame.dtm$stopWord <- csv$stopWord
  data.frame.dtm$langpropname <- csv$langpropname
  data.frame.dtm$scoreComment <- csv$score
  data.frame.dtm$authorComment <- csv$author
  source("src/transformColumns.R")
  data.frame.dtm <- data.frame.dtm %>>%
    transformColums("URLs") %>>%
    transformColums("emoticon") %>>%
    transformColums("Emojis") %>>%
    transformColums("interjection") %>>%
    transformColums("stopWord") %>>%
    transformColums("langpropname")
  rm(transformColums)
}
saveRDS(data.frame.dtm, "files_output_tm/data_frame_dtm_final.rds")
message(green("[Preprocesing][INFO] Finish preprocesing!"))
