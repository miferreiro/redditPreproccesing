source("src/pkgChecker.R")
source("src/read_csv.R")
source("src/write_csv.R")

##################################################################
##                PREPROCESSING USING TM PACKAGE                ##
##################################################################

message(green("[Preprocessing][INFO] Starting preprocessing using tm package..."))
csv <- read_csv(csv = "files_input_tm/outPre_all_comments_september.csv")
csv.corpus <- VCorpus(VectorSource(csv$data))

##################################################################
##                      BASIC PREPROCESING                      ##
##################################################################s

message(blue("[Preprocessing][INFO] Applying basic preprocesing..."))
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

#################################################################
##                         STEMIZATION                         ##
#################################################################

message(blue("[Preprocessing][INFO] Applying stemization..."))
csv.corpus <- tm_map(csv.corpus, stemDocument, language = "english")

#################################################################
##                             DTM                             ##
#################################################################

message(blue("[Preprocessing][INFO] Transforming to dtm..."))
csv.corpus <- tm_map(csv.corpus, stripWhitespace)
csv.corpus <- tm_map(csv.corpus, content_transformer(gsub), pattern = "^\\s+|\\s+$", replacement  = "")
csv.corpus <- tm_map(csv.corpus, content_transformer(gsub), pattern = "\\p{Z}", replacement  = " ", perl = T)
csv.corpus <- tm_map(csv.corpus, content_transformer(trimws))
dtm <- DocumentTermMatrix(csv.corpus)
dtm_tfidf <-  DocumentTermMatrix(csv.corpus,
                           control = list(weighting = weightTfIdf))
saveRDS(dtm, "files_output_tm/out_final_dtm_tm.rds")
saveRDS(dtm_tfidf, "files_output_tm/out_final_dtm_dtm_tfidf_tm.rds")
rm(dtm)
rm(dtm_tfidf)
rm(csv.corpus)
rm(csv)
message(green("[Preprocessing][INFO] Finish preprocessing using tm package!"))
