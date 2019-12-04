source("EC/R/clasification/pkgChecker.R")
source("util/read_csv.R")
source("EC/R/association/transformColumns.R")
csv <- read_csv(csv = "EC/R/association/files/outputPreprocesing.csv")
csv <- csv[1:(dim(csv)[1]/2),]

message(green("[INFO] Applying tm_map..."))
csv.corpus <- VCorpus(VectorSource(csv$data))

csv.corpus <- tm_map(csv.corpus, content_transformer(gsub), pattern = '[²!"“”„#$%&\'()*+,.\\/:;<=>?@\\\\^_\\{\\}|~\\[\\]‘’—-]+', replacement = ' ', perl = T)
csv.corpus <- tm_map(csv.corpus, stripWhitespace)
csv.corpus <- tm_map(csv.corpus, removeNumbers)
removeLongWords <- content_transformer(function(x, length) {

  return(gsub(paste("(?:^|[[:space:]])[[:alnum:]]{", length, ",}(?=$|[[:space:]])", sep = ""), "", x, perl = T))
})
csv.corpus <- tm_map(csv.corpus, removeLongWords, 25)
csv.corpus <- tm_map(csv.corpus, stemDocument,language = "english")

message(green("[INFO] Transforming to DocumentTermMatrix..."))

dtm <- DocumentTermMatrix(csv.corpus)
rm(csv.corpus)
matrix.dtm <- as.matrix(dtm)
rm(dtm)
data.frame.dtm <- as.data.frame(matrix.dtm)
rm(matrix.dtm)

message(green("[INFO] Normalizing columns..."))

data.frame.dtm$URLs <- csv$URLs
data.frame.dtm$emoticon <- csv$emoticon
data.frame.dtm$Emojis <- csv$Emojis
data.frame.dtm$interjection <- csv$interjection
data.frame.dtm$stopWord <- csv$stopWord
data.frame.dtm$langpropname <- csv$langpropname

data.frame.dtm <- data.frame.dtm %>%
  transformColums("URLs") %>%
  transformColums("emoticon") %>%
  transformColums("Emojis") %>%
  transformColums("interjection") %>%
  transformColums("stopWord") %>%
  transformColums("langpropname")

message(green("[INFO] Starting association"))
df.rules <- as(data.frame(lapply(data.frame.dtm, as.character), stringsAsFactors=T), "transactions")

rules <- apriori(df.rules, parameter = list(support = 0.01, confidence = 0.5))
