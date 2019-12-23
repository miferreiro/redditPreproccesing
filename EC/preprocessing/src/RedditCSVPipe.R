RedditCSVPipe <- R6Class(

  "RedditCSVPipe",

  inherit = PipeGeneric,

  public = list(

    initialize = function(propertyName = "",
                          alwaysBeforeDeps = list(),
                          notAfterDeps = list()) {

      if (!"character" %in% class(propertyName)) {
        stop("[RedditCSVPipe][initialize][Error] Checking the type of the variable: propertyName ", class(propertyName))
      }

      if (!"list" %in% class(alwaysBeforeDeps)) {
        stop("[RedditCSVPipe][initialize][Error] Checking the type of the variable: alwaysBeforeDeps ", class(alwaysBeforeDeps))
      }

      if (!"list" %in% class(notAfterDeps)) {
        stop("[RedditCSVPipe][initialize][Error] Checking the type of the variable: notAfterDeps ", class(notAfterDeps))
      }

      super$initialize(propertyName, alwaysBeforeDeps, notAfterDeps)
    },

    pipe = function(instance, withData = TRUE, withSource = TRUE) {

      if (!"Instance" %in% class(instance)) {
        stop("[RedditCSVPipe][pipe][Error] Checking the type of the variable: instance ", class(instance))
      }

      if (!"logical" %in% class(withSource)) {
        stop("[RedditCSVPipe][pipe][Error] Checking the type of the variable: withSource ", class(withSource))
      }

      if (!"logical" %in% class(withData)) {
        stop("[RedditCSVPipe][pipe][Error] Checking the type of the variable: withData ", class(withData))
      }

      outPutPath <- read.ini(Bdpar[["private_fields"]][["configurationFilePath"]])$CSVPath$outPutTeeCSVPipePath
      outPutPath <- paste0(outPutPath,
                           instance$getSpecificProperty("subreddit"),
                           "_september.csv")

      if (!"character" %in% class(outPutPath)) {
        stop("[RedditCSVPipe][pipe][Error] Checking the type of the variable: outPutPath ", class(outPutPath))
      }

      if (!"csv" %in% tools::file_ext(outPutPath)) {
        stop("[RedditCSVPipe][pipe][Error] Checking the extension of the file: outPutPath ", tools::file_ext(outPutPath))
      }

      instance$addFlowPipes("RedditCSVPipe")

      if (!instance$checkCompatibility("RedditCSVPipe", self$getAlwaysBeforeDeps())) {
        stop("[RedditCSVPipe][pipe][Error] Bad compatibility between Pipes.")
      }

      instance$addBanPipes(unlist(super$getNotAfterDeps()))

      if (!instance$isInstanceValid()) {
        return(instance)
      }

      if (file.exists(outPutPath)) {
        dataFrameAll <- read.csv(file = outPutPath, header = TRUE,
                                 sep = ";", dec = ".", fill = FALSE,
                                 stringsAsFactors = FALSE,encoding = "UTF-8" )
      } else {
        dataFrameAll <- data.frame()
      }

      pos <- dim(dataFrameAll)[1] + 1

      dataFrameAll[pos, "path"] <- instance$getPath()

      if (withData) {
        dataFrameAll[pos, "data"] <- instance$getData()
      }

      if (withSource) {
        dataFrameAll[pos, "source"] <-
          as.character(paste0(unlist(instance$getSource())))
      }

      dataFrameAll[pos, "date"] <- instance$getDate()

      namesPropertiesList <- as.list(instance$getNamesOfProperties())
      names(namesPropertiesList) <- instance$getNamesOfProperties()

      for (name in namesPropertiesList) {
        dataFrameAll[pos, name] <-
          paste0(unlist(instance$getSpecificProperty(name)), collapse = "|")
      }

      write.table(x = dataFrameAll,
                  file = outPutPath,
                  sep = ";",
                  dec = ".",
                  quote = TRUE,
                  col.names = TRUE,
                  row.names = FALSE,
                  qmethod = c("double"),
                  fileEncoding = "UTF-8")

      return(instance)
    }
  )
)