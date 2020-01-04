packages.list <- c("crayon", "ggplot2", "tm", "factoextra", "cluster", "pheatmap",
                   "fpc", "grDevices", "graphics", "pvclust", "stats")

message("[Clustering][PkgChecker][INFO] Package Manager")

checkPackages <- function(packages){
  new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if (length(new.packages)) {
    message("[Clustering][PkgChecker][checkPackages][INFO]",length(new.packages)," packages needed to execute aplication\n Installing packages...")
    suppressMessages(install.packages(new.packages,repos = "https://ftp.cixug.es/CRAN/", verbose = FALSE))
  }
}

loadPackages <- function(packages) {
  unload.packages <- packages[!(packages %in% (.packages() ) )  ]
  if (length(unload.packages) > 0) {
    message("[Clustering][PkgChecker][loadPackages][INFO] ",length(unload.packages)," required packages not loaded. Loading packages ...")
    for (lib in unload.packages ) {
      message("[Clustering][PkgChecker][loadPackages][INFO] ",lib)
      library(lib, verbose = FALSE, quietly = FALSE, character.only = TRUE)
    }
  } else message("[PkgChecker][loadPackages][INFO] All packages are loaded")
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