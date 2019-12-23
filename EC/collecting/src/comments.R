cleanComments <- function() {
  files <- list.files(".", all.files = T, recursive = T, include.dirs = F, full.names = T, pattern = "\\.csv")
  filesName <- list.files(".", all.files = T, recursive = T, include.dirs = F, pattern = "\\.csv")
  pos <- 1
  filesName <- filesName[order(file.info(files)$size)]
  files <- files[order(file.info(files)$size)]
  # csv_all <- data.frame()
  for (file in files) {

    cols <- c("author", "author_cakeday", "author_flair_type",
              "author_patreon_flair", "body", "can_gild",
              "controversiality","created_utc","distinguished",
              "gilded", "is_submitter", "locked",
              "mod_removed", "no_follow", "reply_delay",
              "score", "send_replies", "stickied", "subreddit",
              "subreddit_type","total_awards_received", "user_removed")
    csv <- read_csv(file)
    csv <- csv[,cols]
    csv$body <- gsub("\"",
                     "'",
                     csv$body)
    csv$controversiality <- as.numeric(csv$controversiality)
    csv$gilded <- as.numeric(csv$gilded)
    csv$reply_delay <- as.numeric(csv$reply_delay)
    csv$score <- as.numeric(csv$score)
    csv$total_awards_received <- as.numeric(csv$total_awards_received)
    csv$author_patreon_flair <-  as.logical(csv$author_patreon_flair)
    csv$no_follow <-  as.logical(csv$no_follow)
    csv$stickied <- as.logical(csv$stickied)
    csv$locked <- as.logical(csv$locked)
    csv$is_submitter <- as.logical(csv$is_submitter)
    csv$can_gild <- as.logical(csv$can_gild)
    csv <- na.replace(csv, NULL)

    for (i in 1:dim(csv)[1]) {
      for (col in cols) {
        if (!is.na(csv[i,col]) && (is.null(csv[i,col]) || csv[i,col] == "NULL")) {
          csv[i, col] <- NA
        }
        if (!is.na(csv[i,col]) &&  csv[i,col] == "FALSE") {
          csv[i, col] <- FALSE
        }
        if (!is.na(csv[i,col]) &&  csv[i,col] == "TRUE") {
          csv[i, col] <- TRUE
        }
      }
    }
    message(blue("[Collecting][INFO] Writting csv to", filesName[pos]))
    write_csv(csv = csv,
              output.path = filesName[pos],
              col.names = TRUE)

    pos <- pos + 1
    # message(green("[Collecting][INFO] Writting csv to all_comments.csv"))
    # write_csv(csv = csv,
    #           output.path = paste0("all_comments.csv"),append = T)
  }
}