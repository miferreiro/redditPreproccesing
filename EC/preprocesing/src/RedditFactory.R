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
               return(unlist(apply(
                 X = csv, 1,
                 FUN = function(row) {
                   InstanceReddit$new(path,
                                      row["author"],
                                      row["body"],
                                      row["created_utc"],
                                      row["score"],
                                      row["subreddit"])
                 }
               )))
             })

      return()
    }
  )
)