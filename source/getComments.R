sources <- c("configurations/pkgChecker.R",  "util/write_csv.R")
for (s in sources) { suppressMessages(source(s)) }

non_recs <- function(x) x[!sapply(x, is.recursive)]

getComments <- function(subreddits,
                        start.date,
                        end.date,
                        num.comments) {

  if (is.null(subreddits)) {
    message("[getComments][WARNING] subreddit parameter is null. Assuming all subreddits.")
    subreddits <- c("all")
  }
  if (is.null(start.date)) stop("[getComments][ERROR] startDate parameter can not be NULL.")
  if (!is.numeric(start.date)) stop("[getComments][ERROR] startDate parameter must be numeric.")
  if (is.null(end.date)) end.date <- as.numeric(Sys.time())
  if (!is.numeric(end.date)) stop("[getComments][ERROR] endDate parameter must be numeric.")

  #41 columns
  names <- c("author", "author_cakeday", "author_flair_background_color",
             "author_flair_css_class", "author_flair_template_id", "author_flair_text",
             "author_flair_text_color", "author_flair_type", "author_fullname", "author_created_utc",
             "author_patreon_flair", "body", "created_utc", "can_gild",
             "collapsed", "collapsed_reason", "controversiality",
             "distinguished", "gilded", "edited", "id",
             "is_submitter", "link_id", "locked", "mod_removed", "nest_level",
             "no_follow", "parent_id", "permalink", "reply_delay" , "retrieved_on", "score",
             "send_replies", "stickied", "subreddit", "subreddit_id", "subreddit_name_prefixed",
             "subreddit_type", "updated_utc", "user_removed",  "total_awards_received")
  total.posts <- 0
  for (subreddit in subreddits) {
    file <- file.path("data", "comments", paste0("comments_", subreddit, ".csv"))
    actual.date <- start.date
    while (actual.date < end.date) {
      url <- 'https://api.pushshift.io/reddit/comment/search?'
      if (!is.null(subreddit)) {
        url <- paste0(url, "&", "subreddit", "=", subreddit)
      }
      url <- paste0(url, "&", "limit", "=", num.comments)
      url <- paste0(url, "&", "after", "=", actual.date)
      message(white("[getComments][INFO] Requesting the petition:", url))
      r <- httr::GET(url)
      j <- httr::content(r, as = "text", encoding = "UTF-8")
      comments <- jsonlite::fromJSON(j)
      if (length(comments$data) == 0) {
        message(white("[getComments][ERROR] Imposible obtains data from", subreddit,
                      "after", lubridate::as_datetime(actual.date, tz = "CET"), "date"))
        message(white("[getComments][ERROR] Checking next subreddit"))
        break
      }
      comments <- tibble::as_tibble(non_recs(comments$data))
      actual.date <- sort(comments$created_utc, decreasing = TRUE)[1]
      tryCatch(
      {
        message(blue("[getComments][INFO] Biggest date of the comments collected is:",
                     lubridate::as_datetime(actual.date, tz = "CET")))
        comments$created_utc <- lubridate::as_datetime(comments$created_utc, tz = "CET")
      },
      error = function(e) {
        message("[getComments][ERROR] Error in parse created_utc")
        comments$created_utc <- NULL
      })
      message(white("[getComments][INFO] Collected", nrow(comments), "posts"))
      total.posts <- total.posts + nrow(comments)
      message(white("[getComments][INFO] Num colm:", length(names(comments))))
      names.actual <- names(comments)
      new.names <- setdiff(names, names.actual)

      for (name in new.names) {
        comments[, name] <- rep_len(NA, nrow(comments))
        names(comments)[length(comments)] <- name
        names <- c(names, name)
      }

      comments <- comments[, order(c(names(comments)))]

      write_csv(comments, file) #na = "NULL"
    }
    message(green("[getComments][INFO] Total post obtained for", subreddit, "are:", total.posts))
  }
}

subreddits <- c("Fitness", "nutrition", "bodyweightfitness", "homegym",
                "xxfitness", "loseit", "sugarlifestyleforum", "getdisciplined",
                "ketogains", "stopdrinkingfitness", "weightroom", "bodybuilding")

start.date <- as.numeric(as.POSIXlt(x = "2019-01-01 00:00:00", tz = "CET"))
end.date <- as.numeric(as.POSIXlt(x = "2019-09-30 00:00:00", tz = "CET"))
num.comments <- 10000

getComments(subreddits = subreddits,
            start.date = start.date,
            end.date = end.date,
            num.comments = num.comments)

