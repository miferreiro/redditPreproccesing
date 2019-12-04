library(bdpar)
library(R6)
source("EC/R/preprocesing/src/RedditPipes.R")
source("EC/R/preprocesing/src/InstanceReddit.R")
source("EC/R/preprocesing/src/RedditFactory.R")
source("EC/R/preprocesing/src/overwritePreprocesing.R")
source("EC/R/preprocesing/src/RedditCSVPipe.R")

bdpar_object <- Bdpar$new(configurationFilePath = "EC/R/preprocesing/config/configurations.ini",
                          editConfigurationFile = FALSE)

bdpar_object$proccess_files(filesPath = "EC/R/preprocesing/files",
                            pipe = RedditPipes$new(),
                            instanceFactory = RedditFactory$new())


aa <- read_csv("EC/R/preprocesing/outputPreprocesing.csv")
