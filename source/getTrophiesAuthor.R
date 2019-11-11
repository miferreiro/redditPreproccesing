sources <- c("configurations/pkgChecker.R", "util/authentication.R", "util/write_csv.R", "util/read_csv.R", "util/refresh.R")
for (s in sources) suppressMessages(source(s))
if (file.exists(".httr-oauth") &&
    difftime(Sys.time(),file.info(".httr-oauth")$mtime, units = c("mins")) > 60) file.remove(".httr-oauth")

configuration.file <- read.ini("configurations/configurations_trophies.ini")
csvs.files <- list.files(configuration.file$csvs$csvs.folder,include.dirs = F,full.names = T)
#to get permament token: appends on url &duration=permanent
token <<- authentication(configuration.file$reddit$client.id, configuration.file$reddit$client.secret)
num.max.request <- 60
num.request <<- 0
base <- configuration.file$reddit$base
endbase <- configuration.file$reddit$endbase
initial.auth <<- Sys.time()

# csvs.files <- c("data/comments/comments_ketogains.csv", "data/comments/comments_homegym.csv")
csvs.files <- c("data/comments/comments_nutrition.csv")

for (csv in csvs.files) {
  message(green("[INFO] Procesing ", csv))
  reddit.data <- read_csv(csv)
  flag <<- Sys.time()
  num <<- 1
  message("[INFO] Num author to preprocess: ", length(unique(reddit.data$author)))
  lapply(unique(reddit.data$author), function(author, token) {
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

      info.authors.data <- data.frame(matrix(ncol = 0, nrow = 0))
      info.authors.data[1, "author"] <- author
      info.authors.data[1, "num_trophies"] <- length(content$data$trophies)

      write_csv(info.authors.data,
                file.path("data", "trophies", paste0("num_trophies_",  basename(csv))))

      message("[INFO] Quering (", num, " - ", Sys.time(), ") -> ", paste0(base, author, endbase),
              " to ", file.path("data", "trophies", paste0("num_trophies_",  basename(csv))))
      num <<- num + 1
      num.request <<- num.request + 1
    }
  }, token)
}

# a <- read_csv("data/author_info_stopdrinkingfitness.csv")
# a <- read_csv("data/author_info_bodybuilding.csv")
# b <- read_csv("data/num_trophies_ketogains.csv")
