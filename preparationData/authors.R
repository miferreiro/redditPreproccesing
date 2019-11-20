sources <- c("configurations/pkgChecker.R",
             "util/write_csv.R",
             "util/read_csv.R")
for (s in sources) suppressMessages(source(s))

files <- list.files("data/authors/", all.files = T, recursive = T, include.dirs = F, full.names = T)
filesName <- list.files("data/authors/", all.files = T, recursive = T, include.dirs = F)
pos <- 1
filesName <- filesName[order(file.info(files)$size)]
files <- files[order(file.info(files)$size)]

for (file in files) {

  cols <-
    c(
      "author", "is_employee", "pref_show_snoovatar",
      "created", "has_subscribed", "hide_from_robots", "link_karma",
      "comment_karma", "is_gold", "is_mod", "verified", "has_verified_email",
      "over_18", "subscribers", "subreddit_type", "is_suspended"
    )
  csv <- read_csv(file)
  csv <- csv[,cols]

  csv$is_employee <- as.logical(csv$is_employee)
  csv$pref_show_snoovatar <- as.logical(csv$pref_show_snoovatar)
  tryCatch({
    csv$created <- lubridate::as_datetime(csv$created, tz = "CET")
  }, error = function(e) {
    message("[getComments][ERROR] Error in parse created")
    csv$created <- NA
  })

  csv$has_subscribed <- as.logical(csv$has_subscribed)
  csv$hide_from_robots <- as.logical(csv$hide_from_robots)
  csv$link_karma <- as.numeric(csv$link_karma)
  csv$comment_karma <- as.numeric(csv$comment_karma)
  csv$is_gold <- as.logical(csv$is_gold)
  csv$is_mod <- as.logical(csv$is_mod)
  csv$verified <- as.logical(csv$verified)
  csv$has_verified_email <- as.logical(csv$has_verified_email)
  csv$subscribers <- as.numeric(csv$subscribers)
  csv$is_suspended <- as.logical(csv$is_suspended)

  for (i in 1:dim(csv)[1]) {
    for (col in cols) {
      if ( col == "created") next
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


  message(green("[INFO] Writting csv to", filesName[pos]))
  write_csv(csv = csv,
            output.path = paste0("prepararedData/authors/", filesName[pos]))

  pos <- pos + 1
  message(green("[INFO] Writting csv to all_authors.csv"))
  write_csv(csv = csv,
            output.path = paste0("prepararedData/",
                                 "all_authors.csv"), append = T)
}
