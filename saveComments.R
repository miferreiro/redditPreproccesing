library(rlist)
library(crayon)
non_recs <- function(x) {
  x[!sapply(x, is.recursive)]
}

getComments <- function(subreddits,
                        startDate,
                        endDate,
                        numComments = 1,
                        file = "reddit.csv") {
  if (is.null(subreddits)) {
    message("[getComments][INFO] subreddit parameter is null. Assuming all subreddits.")
    subreddits <- c("all")
  }
  if (is.null(startDate)) {
    stop("[getComments][ERROR] startDate parameter can not be NULL.")
  }
  if (is.null(endDate)) {
    endDate <- as.numeric(Sys.time())
  }
  if (!is.numeric(startDate)) {
    stop("[getComments][ERROR] startDate parameter must be numeric.")
  }
  if (!is.numeric(endDate)) {
    stop("[getComments][ERROR] endDate parameter must be numeric.")
  }


  names <- c("author", "author_cakeday", "author_flair_background_color",
             "author_flair_css_class", "author_flair_template_id", "author_flair_text",
             "author_flair_text_color", "author_flair_type", "author_fullname",
             "author_patreon_flair", "body", "created_utc",
             "distinguished", "edited", "id",
             "is_submitter", "link_id", "locked", "no_follow", "parent_id",
             "permalink", "retrieved_on", "score",
             "send_replies", "stickied", "subreddit",
             "subreddit_id", "total_awards_received")

  for (subreddit in subreddits) {

    actualDate <- startDate
    while (actualDate < endDate) {
      url <- 'https://api.pushshift.io/reddit/comment/search?'
      if (!is.null(subreddit)) {
        url <- paste0(url, "&", "subreddit", "=", subreddit)
      }
      url <- paste0(url, "&", "limit", "=", numComments)
      url <- paste0(url, "&", "after", "=", actualDate)
      message(white("[getComments][INFO] Requesting the petition:", url))
      # comments <- jsonlite::fromJSON(base)
      r <- httr::GET(url)
      j <- httr::content(r, as = "text", encoding = "UTF-8")
      comments <- jsonlite::fromJSON(j)
      if (length(comments$data) == 0) {
        message(white("[getComments][ERROR] Imposible obtains data from", subreddit, "after", actualDate, "date"))
        message(white("[getComments][ERROR] Checking next subreddit"))
        break
      }
      comments <- tibble::as_tibble(non_recs(comments$data))
      
      actualDate <- sort(comments$created_utc, decreasing = TRUE)[1]
      
      tryCatch(
      {
        message(blue("[getComments][INFO] Biggest date of the comments collected is:", lubridate::as_datetime(actualDate, tz = "CET")))
        comments$created_utc <- lubridate::as_datetime(comments$created_utc, tz = "CET")
      }
      ,
      error = function(e) {
        message("[getComments][ERROR] Error in parse created_utc")
        comments$created_utc <- NULL
      }
      )
      message(green("[getComments][INFO] Collected", nrow(comments), "posts"))
      message(white("[getComments][INFO] Saving comments on:", file, "file."))
      message(white("[getComments][INFO] Num colm:", length(names(comments))))
      namesActual <- names(comments)
      newNames <- setdiff(names, namesActual)
      # newNames <- setdiff(namesActual, names)
      for (name in newNames) {
        comments[, name] <- rep_len(NA, nrow(comments))
        names(comments)[length(comments)] <- name
        names <- c(names, name)
      }
      comments <- comments[, order(c(names(comments)))]
      if (!file.exists(file)) {
        message(red("[getComments][INFO]", file, "file does not exist. Creating new file..."))
      }
      write.table(
        x = comments,
        file = file,
        append = TRUE,
        sep = ";",
        dec = ".",
        quote = TRUE,
        col.names = !file.exists(file),
        row.names = FALSE,
        qmethod = c("double"),
        fileEncoding = "UTF-8",
        na = "NULL"
      )
    }
  }
}

# subreddits <- c("Fitness", "nutrition", "bodyweigthfitness", "homegym")
subreddits <- c("bodyweigthfitness", "homegym")
startDate <- as.numeric(as.POSIXlt(x = "2019-10-03 17:01:00", tz = "CET"))
endDate <- as.numeric(as.POSIXlt(x = "2019-10-03 17:02:00", tz = "CET"))
numComments <- 1000
file <- "homegym.csv"
# suppressMessages(getComments(subreddit = subreddit,
#             startDate = startDate,
#             endDate = endDate,
#             numComments = numComments,
#             file = file))

getComments(subreddits = subreddits,
            startDate = startDate,
            endDate = endDate,
            numComments = numComments,
            file = file)

dataFrameAll <- read.csv(
  file = file,
  header = TRUE,
  sep = ";",
  dec = ".",
  fill = FALSE,
  stringsAsFactors = FALSE
)

