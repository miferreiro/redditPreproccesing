sources <- c("extractionData/configurations/pkgChecker.R",
             "util/write_csv.R",
             "util/read_csv.R")
for (s in sources) suppressMessages(source(s))

files <- list.files("extractionData/data/subreddits", all.files = T, recursive = T, include.dirs = F, full.names = T)
filesName <- list.files("extractionData/data/subreddits", all.files = T, recursive = T, include.dirs = F)
pos <- 1
for (file in files) {

  cols <-
    c(
      "restrict_posting", "free_form_reports", "wiki_enabled", "display_name",
      "title", "active_user_count", "accounts_active", "subscribers",
      "emojis_enabled", "advertiser_category", "public_description",
      "comment_score_hide_mins",
      "original_content_tag_enabled", "submit_text", "spoilers_enabled",
      "all_original_content", "has_menu_widget", "wls",
      "submission_type", "allow_videogifs", "collapse_deleted_comments",
      "allow_videos", "submit_text_label", "subreddit_type",
      "show_media", "over18", "description",
      "restrict_commenting", "allow_images", "lang", "whitelist_status", "created_utc"
    )
  csv <- read_csv(file)
  csv <- csv[,cols]
  csv$submit_text <- gsub("\"",
                          "'",
                          csv$submit_text)
  csv$submit_text <- gsub("#",
                          " ",
                          csv$submit_text)
  csv$submit_text <- gsub("\\[",
                          " ",
                          csv$submit_text)
  csv$submit_text <- gsub("\\]",
                          " ",
                          csv$submit_text)
  csv$submit_text <- gsub("\n+",
                          " ",
                          csv$submit_text)
  csv$description <- gsub("\"",
                          "'",
                          csv$description)
  csv$description <- gsub("#",
                          " ",
                          csv$description)
  csv$description <- gsub("\\[",
                          " ",
                          csv$description)
  csv$description <- gsub("\\]",
                          " ",
                          csv$description)
  csv$description <- gsub("\n+",
                          " ",
                          csv$description)
  csv$restrict_posting <- as.logical(csv$restrict_posting)
  csv$free_form_reports <- as.logical(csv$free_form_reports)
  csv$wiki_enabled <- as.logical(csv$wiki_enabled)
  csv$active_user_count <- as.numeric(csv$active_user_count)
  csv$accounts_active <- as.numeric(csv$accounts_active)
  csv$subscribers <- as.numeric(csv$subscribers)
  csv$emojis_enabled <- as.logical(csv$emojis_enabled)
  csv$comment_score_hide_mins <- as.numeric(csv$comment_score_hide_mins)
  csv$original_content_tag_enabled <- as.logical(csv$original_content_tag_enabled)
  csv$spoilers_enabled <- as.logical(csv$spoilers_enabled)
  csv$all_original_content <- as.logical(csv$all_original_content)
  csv$has_menu_widget <- as.logical(csv$has_menu_widget)
  csv$wls <- as.numeric(csv$wls)
  csv$allow_videogifs <- as.logical(csv$allow_videogifs)
  csv$collapse_deleted_comments <- as.logical(csv$collapse_deleted_comments)
  csv$allow_videos <- as.logical(csv$allow_videos)
  csv$show_media <- as.logical(csv$show_media)
  csv$over18 <- as.logical(csv$over18)
  csv$restrict_commenting <- as.logical(csv$restrict_commenting)
  csv$allow_images <- as.logical(csv$allow_images)


  csv <- na.replace(csv, NULL)
  for (i in 1:dim(csv)[1]) {
    for (col in cols) {
      if (!is.na(csv[i,col]) && (is.null(csv[i,col]) || csv[i,col] == "NULL")) {
        csv[i,col] <- NA
      }
      if (!is.na(csv[i,col]) &&  csv[i,col] == "FALSE") {
        csv[i,col] <- FALSE
      }
      if (!is.na(csv[i,col]) &&  csv[i,col] == "TRUE") {
        csv[i,col] <- TRUE
      }
    }
  }

  names(csv) <-  c(
      "restrict_posting", "free_form_reports", "wiki_enabled", "display_name",
      "title", "active_user_count", "accounts_active", "subscribers",
      "emojis_enabled", "advertiser_category", "public_description",
      "comment_score_hide_mins",
      "original_content_tag_enabled", "submit_text", "spoilers_enabled",
      "all_original_content", "has_menu_widget", "wls",
      "submission_type", "allow_videogifs", "collapse_deleted_comments",
      "allow_videos", "submit_text_label", "type",
      "show_media", "over18", "description",
      "restrict_commenting", "allow_images", "lang", "whitelist_status", "created_utc"
    )

  message(green("[INFO] Writting csv to", filesName[pos]))
  write_csv(csv = csv,
            output.path = paste0("extractionData/prepararedData/subreddits/", filesName[pos]))
  pos <- pos + 1
}
