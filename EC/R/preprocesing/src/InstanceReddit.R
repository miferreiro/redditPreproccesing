InstanceReddit <- R6::R6Class(
  classname = "InstanceReddit",
  inherit = bdpar::Instance,
  public = list(
    initialize = function(path,
                          author,
                          body,
                          created_utc,
                          distinguised,
                          is_submiter,
                          mod_removed,
                          no_follow,
                          reply_delay,
                          score,
                          subreddit) {

      if (!"character" %in% class(path)) {
        stop("[InstanceReddit][initialize][Error]",
                "Checking the type of the variable: path ",
                  class(path))
      }
      super$initialize(path)
      super$addProperties(author, "author")
      super$addProperties(gsub(pattern = "\n+",replacement = " ", x = body), "body")
      # super$addProperties(created_utc, "created_utc")
      # super$addProperties(distinguised, "distinguised")
      # super$addProperties(is_submiter, "is_submiter")
      # super$addProperties(mod_removed, "mod_removed")
      # super$addProperties(no_follow, "no_follow")
      # super$addProperties(reply_delay, "reply_delay")
      super$addProperties(score, "score")
      # super$addProperties(subreddit, "subreddit")
    },
    obtainSource = function() {
      super$setSource(super$getSpecificProperty("body"))
      super$setData(super$getSource())
      return()
    }
  )
)