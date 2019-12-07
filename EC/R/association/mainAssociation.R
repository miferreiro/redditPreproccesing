source("EC/R/association/pkgChecker.R");source("util/read_csv.R");source("EC/R/association/transformColumns.R")
csv <- read_csv(csv = "EC/R/association/files/outputPreprocesing.csv")
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


dtm <- DocumentTermMatrix(csv.corpus, control = list(weighting =
                                                       function(x)
                                                         weightTfIdf(x, normalize = FALSE)))

dtm <- DocumentTermMatrix(csv.corpus)
# saveRDS(dtm, "EC/R/association/saveFilesRDS/dtm.RDS")

#################################################################
##                           END DTM                           ##
#################################################################

#################################################################
##                     Normalizing columns                     ##
#################################################################

# dtm <- readRDS("EC/R/association/saveFilesRDS/dtm.RDS")
rm(csv.corpus)
matrix.dtm <- as.matrix(dtm)
rm(dtm)
data.frame.dtm <- as.data.frame(matrix.dtm)
names(data.frame.dtm)
rm(matrix.dtm)

message(green("[INFO] Normalizing columns..."))
{
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

}

# saveRDS(data.frame.dtm, "EC/R/association/saveFilesRDS/data-frame-dtm.RDS")

################################################################################
message(green("[INFO] Starting association"))

df.rules <- as(data.frame(lapply(data.frame.dtm, as.character), stringsAsFactors = T), "transactions")
summary(df.rules)
# image(df.rules)
# saveRDS(df.rules, "EC/R/association/saveFilesRDS/df-rulesv1.rds")

# La generación de reglas se realiza fijando:
# Soporte: Proporción de transacciones en la base de datos que contiene cada conjunto de items.
# Confianza: Porcentaje de veces que se cumple la regla en la que se encuentran los items.
rules <- apriori(df.rules, 
                 parameter = list(support = 0.9, confidence = 0.9, minlen = 3, maxlen = 10, target = "rules", maxtime=300), 
                 control = list(verbose = T, memopt = T, sort = -1))

inspect(rules)
# rules_unique <- rules[-which(colSums(is.subset(rules, rules)) > 1)]


saveRDS(rules, "EC/R/association/saveFilesRDS/rulesv1.rds")

# 
rules_lift <- sort(rules, by = "lift", decreasing = TRUE)
top10subRules <- head(rules, n = 10, by = "confidence")
# plot(top10subRules, method = "graph",engine = "htmlwidget")



# rules_fpgrowth <- rCBA::fpgrowth(df.rules, support=0.9, confidence=0.9, maxLength=2)
# rulesFrame <- as(rules_fpgrowth,"data.frame")
# 
# predictions <- rCBA::classification(train,rulesFrame)
# table(predictions)
# sum(train$Species==predictions,na.rm=TRUE)/length(predictions)
# 
# prunedRulesFrame <- rCBA::pruning(train, rulesFrame, method="m2cba")
# predictions <- rCBA::classification(train, prunedRulesFrame)
# table(predictions)
# sum(train$Species==predictions,na.rm=TRUE)/length(predictions)