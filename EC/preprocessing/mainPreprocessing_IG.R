source("src/pkgChecker.R")
source("src/read_csv.R")
source("src/write_csv.R")

##################################################################
##   PREPROCESSING: FEATURE SELECTION USING INFORMATION GAIN    ##
##################################################################

message(green("[Preprocessing][INFO] Starting preprocesing: feature selection using information gain..."))

csv <- read_csv(csv = "files_input_IG/outPre_all_comments_september.csv")
# dtm <- readRDS("files_input_IG/out_final_dtm_tm.rds")
dtm <- readRDS("files_input_IG/out_final_dtm_tfidf_tm.rds")

target <- csv$subreddit
final.ig <- c()

for (col in seq_len(dim(dtm)[2])) {
  message(blue("[Preprocessing][INFO] IG: ", Terms(dtm)[col], " [", col, "/", dim(dtm)[2], "]" ))

  data <- as.data.frame(cbind(target,as.vector(dtm[,col])))

  names(data) <- c("nameOfSubreddit",
                   Terms(dtm)[col])

  result_ig <- as.character(RWeka::InfoGainAttributeEval(as.formula("nameOfSubreddit~."),
                                                         data))

  message(blue("[Preprocessing][INFO] Result IG for ", Terms(dtm)[col], ": ", result_ig))

  final.ig <- c(final.ig,
                result_ig)

  names(final.ig)[length(final.ig)] <- Terms(dtm)[col]
}

# saveRDS(object = final.ig, file = "files_output_IG/out_IG.rds")
saveRDS(object = final.ig, file = "files_output_IG/out_tfidf_IG.rds")

# final.ig <- readRDS(file = "files_output_IG/out_IG.rds")
final.ig <- readRDS(file = "files_output_IG/out_tfidf_IG.rds")

dtm <- dtm[, names(sort(final.ig))[1:1000]]

# saveRDS(object = dtm, file = "files_output_IG/out_dtm_IG.rds")
saveRDS(object = dtm, file = "files_output_IG/out_dtm_tfidf_IG.rds")
s

##################################################################
##            CREATION OF THE FINAL DATAFRAME WITH:             ##
##                 THE SELECTED FEATURES WITH IG                ##
##                              +                               ##
##        THE OBTAINED FEATURES THROUGH THE BDPAR PACKAGE       ##
##################################################################

matrix.dtm <- as.matrix(dtm)
rm(dtm)
matrix.dtm <- cbind(csv$subreddit, matrix.dtm)
colnames(matrix.dtm)[1] <- "nameOfSubreddit"
data.frame.dtm <- as.data.frame(matrix.dtm)
rm(matrix.dtm)
message(blue("[Preprocessing][INFO] Dimension of final data frame: "),
        paste(dim(data.frame.dtm), collapse = " "))
message(blue("[Preprocessing][INFO] Normalizing columns..."))
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

saveRDS(data.frame.dtm, "files_output_IG/out_data_frame.rds")


message(green("[Preprocessing][INFO] Finish preprocessing: feature selection using information gain"))

