source("src/pkgChecker.R")
source("src/read_csv.R")
source("src/write_csv.R")
source("src/information_gain.R")
library(FSelector)
csv <- read_csv(csv = "files_input_tm/outPre_all_comments_september.csv")
dtm <- readRDS("files_output_tm/dtm_without_stem-lemma.rds")

target <- csv$subreddit
final.ig <- c()
col <- 1
for (col in seq_len(dim(dtm)[2])) {
  message("IG:", Terms(dtm)[col], " [", col, "/", dim(dtm)[2], "]" )
  
  data <- as.data.frame(cbind(target,as.vector(dtm[,col])))
  names(data) <- c("nameOfSubreddit", Terms(dtm)[col])
  
  result_ig <- as.character(RWeka::InfoGainAttributeEval(as.formula("nameOfSubreddit~."), data))
  # result_ig <- as.character(information_gain("nameOfSubreddit", data))
  
  message("Result IG for ", Terms(dtm)[col], ": ", result_ig)
  
  final.ig <- c(final.ig, result_ig)
  names(final.ig)[length(final.ig)] <- Terms(dtm)[col]
  col <- col + 1
}

saveRDS(object = final.ig, file = "files_output_IG/result_ig_without_stem.rds")

final.ig <- readRDS(file = "files_output_IG/result_ig_without_stem.rds")
dtm <- dtm[,names(sort(final.ig))[1:1000]]

saveRDS(object = dtm, file = "files_output_IG/result_ig_dtm_without_stem.rds")

csv <- read_csv(csv = "files_input_tm/outPre_all_comments_september.csv")

matrix.dtm <- as.matrix(dtm)
rm(dtm)
matrix.dtm <- cbind(csv$subreddit, matrix.dtm)
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
saveRDS(data.frame.dtm, "files_output_IG/result_ig_data_frame_dtm_without_stem.rds")
message(green("[Preprocesing][INFO] Finish preprocesing!"))

