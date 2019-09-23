library(data.table)
data <- readRDS("dataReddit.rds")
#Dan data.frame author_flair_richtext   gildings      
{
names <- c("all_awardings",                 "approved_at_utc",               "author",
           "author_flair_background_color", "author_flair_css_class",        "author_flair_richtext",
           "author_flair_template_id",      "author_flair_text",             "author_flair_text_color",
           "author_flair_type",             "author_fullname",               "author_patreon_flair",
           "banned_at_utc",                 "body",                          "can_mod_post",
           "collapsed",                     "collapsed_reason",              "created_utc",
           "distinguished",                 "edited",                        "gildings",
           "id",                            "is_submitter",                  "link_id",
           "locked",                        "no_follow",                     "parent_id",
           "permalink",                     "retrieved_on",                  "score",
           "send_replies",                  "steward_reports",               "stickied",
           "subreddit",                     "subreddit_id",                  "total_awards_received",
           "author_cakeday",                "media_metadata")
}
dataset <- data.table(matrix(ncol = 38, nrow = 0))
error <- list()
colnames(dataset) <- names

cont <- 77
# cont <- 1
for (d in data) {
  message("[INFO] Lista en data ", cont)
  cont <- cont + 1
  dataFrame <- d$data
  numRows <- dim(dataset)[1]
  for (col in names(dataFrame)) {
    for (numRow in 1:dim(dataFrame)[1]) {
      class <- class(dataFrame[numRow, col])
      if ("list" %in% class) {
        if (is.null(dataFrame[numRow, col][[1]]) || length(dataFrame[numRow, col][[1]]) == 0) {
          value <- NA
        } else {
          if ("data.frame" %in% class(dataFrame[[numRow, col]])) {
            value <- I(list(dataFrame[numRow, col]))
          } else {
            value <- dataFrame[[numRow, col]]
          }
        }
      } else {
        if ("data.frame" %in% class) {
          if (dim(dataFrame[numRow, col])[2] == 0 ) {
            value <- NA
          } else {
            value <- I(list(dataFrame[numRow, col]))
          }
        } else {
          value <- dataFrame[[numRow, col]]
        }
      }
      tryCatch({
        dataset[[numRows + numRow, col]] <- value
      }, error = function(e) {
        message(e)
        message("[INFO] Clase del elemento que ha dado error: ", class(value))
        message("[INFO] Valor del elemento que ha dado error: \n", value)
        error <- list.append(error, value)
        Sys.sleep(10)
      }
      )  
    }
  }
}

rm(d)
rm(n)


saveRDS(dataset, "dataset.rds")
write.csv(dataset, file = "dataset.csv")