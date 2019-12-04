source("util/read_csv.R")

RedditFactory <- R6Class(
  "RedditFactory",
  inherit = InstanceFactory,
  public = list(
    initialize = function() {
    },
    createInstance = function(path) {
      if (!"character" %in% class(path)) {
        stop("[RedditFactory][createInstance][Error]",
                "Checking the type of the variable: path ",
                  class(path))
      }

      switch(tools::file_ext(path),
             `csv` =   {
               csv <- read_csv(path)
               csv <- csv[54854:dim(csv)[1],]
               return(unlist(apply(
                 X = csv, 1,
                 FUN = function(row) {
                   InstanceReddit$new(path,
                                      row["author"],
                                      row["body"],
                                      row["created_utc"],
                                      row["distinguised"],
                                      row["is_submiter"],
                                      row["mod_removed"],
                                      row["no_follow"],
                                      row["reply_delay"],
                                      row["score"],
                                      row["subreddit"])
                 }
               )))
             })

      return()
    }
  )
)