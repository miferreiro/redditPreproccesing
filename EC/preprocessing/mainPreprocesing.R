source("src/pkgChecker.R")
source("src/read_csv.R")
source("src/write_csv.R")

message(green("[Preprocesing][INFO] Starting preprocesing..."))

##################################################################
##              PREPROCESSING USING BDPAR PACKAGE               ##
##################################################################

message(green("[Preprocesing][INFO] Starting preprocesing using bdpar package..."))
source("src/RedditPipes.R")
source("src/InstanceReddit.R")
source("src/RedditFactory.R")
source("src/overwritePreprocesing.R")
source("src/RedditCSVPipe.R")

bdpar_object <- Bdpar$new(configurationFilePath = "config/configurations.ini")

bdpar_object$proccess_files(filesPath = "files_input",
                            pipe = RedditPipes$new(),
                            instanceFactory = RedditFactory$new())

files_output <- list.files(path = "files_output/",
                           all.files = T,
                           include.dirs = F,
                           full.names = T,
                           recursive = T)

final <- data.frame()
for (file in files_output) {
  message(blue("[Preprocesing][INFO] Rbind ", file, " wit all..."))
  final <- rbind(final, read_csv(file))
}

write_csv(csv = final,
          output.path = "all_comments_september.csv")

rm(final)
rm(files_output)
rm(bdpar_object)
rm(RedditCSVPipe)
rm(RedditFactory)
rm(RedditPipes)
rm(InstanceReddit)
rm(Bdpar)
##################################################################
##                PREPROCESSING USING TM PACKAGE                ##
##################################################################
message(green("[Preprocesing][INFO] Starting preprocesing using tm package..."))
csv <- read_csv(csv = "all_comments_september.csv")
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
csv.corpus <- tm_map(csv.corpus, content_transformer(gsub), pattern = '[éÅ¾ž…·µ×,‚£«»•²!"“”„#$%&\'`´()*+.\\/:;<=>?@\\\\^_\\{\\}|~\\[\\]‘’—–-]+', replacement = ' ', perl = T)
removeLongWords <- content_transformer(function(x, length) {
  return(gsub(paste("(?:^|[[:space:]])[[:alnum:]]{", length, ",}(?=$|[[:space:]])", sep = ""), "", x, perl = T))
})
csv.corpus <- tm_map(csv.corpus, removeLongWords, 25);rm(removeLongWords)
csv.corpus <- tm_map(csv.corpus, removeWords, preposition)
csv.corpus <- tm_map(csv.corpus, removeWords, BuckleySaltonSWL)
##################################################################
##                         LEMATIZATION                         ##
##################################################################
message(blue("[Preprocesing][INFO] Applying lematization..."))
csv.corpus <- tm_map(csv.corpus, lemmatize_words)
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
##################################################################
##                   REMOVE MEANINGLESS WORDS                   ##
##################################################################
message(blue("[Preprocesing][INFO] Taking most frequency terms..."))
all_tokens <- findFreqTerms(dtm, 1)
tokens_to_remove <- setdiff(findFreqTerms(dtm, 1), findFreqTerms(dtm, lowfreq = 2000))
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
rm(csv.corpus)
saveRDS(dtm, "dtm_final.rds")
dtm <- readRDS("dtm_final.rds")
#################################################################
##                           END DTM                           ##
#################################################################
#################################################################
##                     Normalizing columns                     ##
#################################################################
matrix.dtm <- as.matrix(dtm)
rm(dtm)
matrix.dtm <- cbind(as.factor(csv$subrredit), matrix.dtm)
colnames(matrix.dtm)[1] <- "nameOfSubreddit"
data.frame.dtm <- as.data.frame(matrix.dtm)
rm(matrix.dtm)
message(blue("[Preprocesing][INFO] Dimension of final data frame: ", dim(data.frame.dtm)))
message(blue("[Preprocesing][INFO] Normalizing columns..."))
{
  data.frame.dtm$URLs <- csv$URLs
  data.frame.dtm$emoticon <- csv$emoticon
  data.frame.dtm$Emojis <- csv$Emojis
  data.frame.dtm$interjection <- csv$interjection
  data.frame.dtm$stopWord <- csv$stopWord
  data.frame.dtm$langpropname <- csv$langpropname
  source("src/transformColumns.R")
  data.frame.dtm <- data.frame.dtm %>%
    transformColums("URLs") %>%
    transformColums("emoticon") %>%
    transformColums("Emojis") %>%
    transformColums("interjection") %>%
    transformColums("stopWord") %>%
    transformColums("langpropname")
  rm(transformColums)
}
saveRDS(data.frame.dtm, "data_frame_dtm_final.rds")
message(green("[Preprocesing][INFO] Finish preprocesing!"))