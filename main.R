library(rlist)
getComments <- function(subredit, 
                        startDate, 
                        endDate) {
  if (is.null(startDate)) {
    stop("[getComments][ERROR] startDate parameter can not be NULL")
  }
  if (is.null(endDate)) {
    endDate <- as.numeric(Sys.time())
  }
  if (!is.numeric(startDate)) {
    stop("[getComments][ERROR] startDate parameter must be numeric")
  }
  if (!is.numeric(endDate)) {
    stop("[getComments][ERROR] endDate parameter must be numeric")
  }
  
  actualDate <- startDate
  allComments <- list()
  
  while (actualDate < endDate) {
    base <- 'https://api.pushshift.io/reddit/comment/search?'
    
    if (!is.null(subredit)) {
      base <- paste0(base, "&", "subredit", "=", subredit)
    }
    
    base <- paste0(base, "&", "limit", "=", 1000)
    
    base <- paste0(base, "&", "after", "=", actualDate)
    
    comments <- jsonlite::fromJSON(base)
    
    actualDate <- sort(comments$data$created_utc, decreasing = TRUE)[1]
    print(lubridate::as_datetime(actualDate, tz = "CET"))
    
    
    comments$data$created_utc <- lubridate::as_datetime(comments$data$created_utc, tz = "CET")
    
    allComments <- list.append(allComments, comments)
    
    if (dim(comments$data)[1] != 1000) {
      break
    }
  }
  allComments
}

subredit <- "drug"
startDate <- as.numeric(as.POSIXlt(x = "2019-09-22 16:00:00", tz = "CET"))
endDate <- as.numeric(as.POSIXlt(x = "2019-09-22 17:00:00", tz = "CET"))
data <- getComments(subredit = subredit, startDate = startDate, endDate = endDate)

saveRDS(data, "dataReddit.rds")

