sources <- c("configurations/pkgChecker.R", "util/authentication.R", "util/write_csv.R", "util/read_csv.R", "util/refresh.R")
for (s in sources) suppressMessages(source(s))
if (file.exists(".httr-oauth") &&
    difftime(Sys.time(),file.info(".httr-oauth")$mtime, units = c("mins")) > 60) file.remove(".httr-oauth")

configuration.file <- read.ini("configurations/configurations_authors.ini")
csvs.files <- list.files(configuration.file$csvs$csvs.folder,
                         include.dirs = F,
                         full.names = T)

#to get permament token: appends on url &duration=permanent
token <<- authentication(configuration.file$reddit$client.id, configuration.file$reddit$client.secret)
num.max.request <<- 60
num.request <<- 0
base <- configuration.file$reddit$base
endbase <- configuration.file$reddit$endbase
initial.auth <<- Sys.time()
for (csv in csvs.files) {
  message(green("[INFO] Procesing ", csv))
  reddit.data <- read_csv(csv)
  flag <<- Sys.time()
  num <<- 1
  message("[INFO] Num author to preprocess: ", length(unique(reddit.data$author)))
  lapply(unique(reddit.data$author)[25204:length(unique(reddit.data$author))], function(author) {
    author <- "SwoleNattyNats"
    if (difftime(Sys.time(), initial.auth, units = c("mins")) > 59) {
      message(white("[INFO] Refreshing... (", Sys.time(), ")"))
      cred <- refresh(token$endpoint, token$app, token$credentials,
                      token$params$user_params, token$params$use_basic_auth,
                      config_init = token$params$config_init)
      if (is.null(cred)) {
        remove_cached_token(token)
      } else {
        token$credentials <<- cred
        token$cache()
      }
      message(green("[INFO] Refreshing...(", Sys.time(), ")"))
      initial.auth <<- Sys.time()
    } else {
    # token <<- authentication(configuration.file$reddit$client.id, configuration.file$reddit$client.secret)
    # message("[INFO] Token expires_in: ", token$credentials$expires_in)
    }

    if (author == "[deleted]") {

      message("[WARNING] Author deleted (", num, " - ", Sys.time(), ") -> ", paste0(base, author, endbase),
              " to ", file.path("data", "authors", paste0("authors_info_",  basename(csv))))
      num <<- num + 1
    } else {
      if (num.request == num.max.request) {
        num.request <<- 0
        if (difftime(Sys.time(), flag, units = c("secs")) < 60) {
          message("[INFO] Waiting to complete 60s : ", 60 - difftime(Sys.time(), flag, units = c("secs")))
          Sys.sleep(60 - difftime(Sys.time(), flag, units = c("secs")))
          flag <<- Sys.time()
        }
      }

      response <- httr::GET(paste0(base, author, endbase),
                            add_headers(Authorization = paste("bearer", token$credentials$access_token),
                                        "User-Agent" = "plin21"))
      content <- jsonlite::fromJSON(httr::content(response, as = "text", encoding = "UTF-8"))

      if (length(content$data) != 17) {
        if (length(content$data) == 0) {
          print(httr::content(response, as = "text", encoding = "UTF-8"))
        } else {
          message(red("[INFO] Quering (", num, " - ", Sys.time(), ") -> ", paste0(base, author, endbase),
                      " to ", file.path("data", "authors", paste0("authors_info_",  basename(csv)))))
          message(red("[INFO] Names of columns (", length(content$data),") -> ", paste(names(content$data), collapse = " ")))
        }
      }

      if (!is.null(content$data$created) && !is.POSIXct(content$data$created)) {
        content$data$created <- lubridate::as_datetime(content$data$created, tz = "CET")
      }
{
      if (is.null(content$data$is_employee)) content$data$is_employee <- NA
      if (is.null(content$data$pref_show_snoovatar)) content$data$pref_show_snoovatar <- NA
      if (is.null(content$data$created)) content$data$created <- NA
      if (is.null(content$data$has_subscribed)) content$data$has_subscribed <- NA
      if (is.null(content$data$hide_from_robots)) content$data$hide_from_robots <- NA
      if (is.null(content$data$link_karma)) content$data$link_karma <- NA
      if (is.null(content$data$comment_karma)) content$data$comment_karma <- NA
      if (is.null(content$data$is_gold)) content$data$is_gold <- NA
      if (is.null(content$data$is_mod)) content$data$is_mod <- NA
      if (is.null(content$data$verified)) content$data$verified <- NA
      if (is.null(content$data$has_verified_email)) content$data$has_verified_email <- NA
      if (is.null(content$data$subreddit$over_18)) content$data$subreddit$over_18 <- NA
      if (is.null(content$data$subreddit$subscribers)) content$data$subreddit$subscribers <- NA
      if (is.null(content$data$subreddit$subreddit_type)) content$data$subreddit$subreddit_type <- NA
      if (is.null(content$data$id)) content$data$id <- NA
      if (is.null(content$data$is_suspended)) content$data$is_suspended <- NA

      info.authors.data <- data.frame(matrix(ncol = 0, nrow = 0))

      info.authors.data[1, "author"] <- author
      info.authors.data[1, "is_employee"] <- content$data$is_employee
      info.authors.data[1, "pref_show_snoovatar"] <- content$data$pref_show_snoovatar
      info.authors.data[1, "created"] <- content$data$created
      info.authors.data[1, "has_subscribed"] <- content$data$has_subscribed
      info.authors.data[1, "hide_from_robots"] <- content$data$hide_from_robots
      info.authors.data[1, "link_karma"] <- content$data$link_karm
      info.authors.data[1, "comment_karma"] <- content$data$comment_karma
      info.authors.data[1, "is_gold"] <- content$data$is_gold
      info.authors.data[1, "is_mod"] <- content$data$is_mod
      info.authors.data[1, "verified"] <- content$data$verified
      info.authors.data[1, "has_verified_email"] <- content$data$has_verified_email
      info.authors.data[1, "over_18"] <- content$data$subreddit$over_18
      info.authors.data[1, "subscribers"] <- content$data$subreddit$subscribers
      info.authors.data[1, "subreddit_type"] <- content$data$subreddit$subreddit_type
      info.authors.data[1, "id"] <- content$data$id
      info.authors.data[1, "is_suspended"] <- content$data$is_suspended

}
      write_csv(info.authors.data,
                file.path("data", "authors", paste0("authors_info_",  basename(csv))))

      message("[INFO] Quering (", num, " - ", Sys.time(), ") -> ", paste0(base, author, endbase),
              " to ", file.path("data", "authors", paste0("authors_info_",  basename(csv))))
      num <<- num + 1
      num.request <<- num.request + 1

    }
  })
}
