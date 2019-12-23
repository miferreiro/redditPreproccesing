RedditPipes <- R6Class(
  "RedditPipes",
  inherit = TypePipe,
  public = list(
    initialize = function() { },
    pipeAll = function(instance) {
      if (!"Instance" %in% class(instance)) {
        stop("[RedditPipes][pipeAll][Error]
                Checking the type of the variable: instance ",
                  class(instance))
      }
      tryCatch({
        instance %>I%
          bdpar::StoreFileExtPipe$new()$pipe() %>I%
          bdpar::File2Pipe$new(alwaysBeforeDeps = list())$pipe() %>I%
          bdpar::MeasureLengthPipe$new()$pipe("length_before_cleaning_text") %>I%
          bdpar::FindUrlPipe$new()$pipe() %>I%
          bdpar::FindEmoticonPipe$new()$pipe() %>I%
          bdpar::FindEmojiPipe$new()$pipe() %>I%
          bdpar::GuessLanguagePipe$new(alwaysBeforeDeps = list())$pipe() %>I%
          bdpar::ContractionPipe$new()$pipe() %>I%
          bdpar::AbbreviationPipe$new()$pipe() %>I%
          bdpar::SlangPipe$new()$pipe() %>I%
          bdpar::ToLowerCasePipe$new()$pipe() %>I%
          bdpar::InterjectionPipe$new()$pipe() %>I%
          bdpar::StopWordPipe$new()$pipe() %>I%
          bdpar::MeasureLengthPipe$new()$pipe("length_after_cleaning_text") %>I%
          RedditCSVPipe$new()$pipe(withSource = F)

        return(instance)},
      error = function(e) {
        message("[RedditPipes][pipeAll][Error]", instance$getPath()," :", paste(e), "\n")
        instance$invalidate()
      }
      )
    }
  )
)
