packages.list <- c("crayon", "tm", "wordcloud", "stackoverflow", "ggplot2")

message("[Wordcloud][PkgChecker][INFO] Package Manager")

checkPackages <- function(packages) {
  new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if (length(new.packages)) {
    message("[Wordcloud][PkgChecker][checkPackages][INFO]",
            length(new.packages),
            " packages needed to execute aplication. Installing packages...")
    suppressMessages(install.packages(new.packages,
                                      repos = "https://ftp.cixug.es/CRAN/",
                                      verbose = FALSE))
  }
}

loadPackages <- function(packages) {
  unload.packages <- packages[!(packages %in% (.packages() ) )  ]
  if (length(unload.packages) > 0) {
    message("[Wordcloud][PkgChecker][loadPackages][INFO] ",
            length(unload.packages),
            " required packages not loaded. Loading packages ...")
    for (lib in unload.packages ) {
      message("[Wordcloud][PkgChecker][loadPackages][INFO] ",
              lib)
      library(lib,
              verbose = FALSE,
              quietly = FALSE,
              character.only = TRUE)
    }
  } else message("[Wordcloud][PkgChecker][loadPackages][INFO] All packages are loaded")
}

verifyandLoadPackages <- function() {
  checkPackages(packages.list)
  loadPackages(packages.list)
}

verifyandLoadPackages()

rm(packages.list)
rm(checkPackages)
rm(loadPackages)
rm(verifyandLoadPackages)