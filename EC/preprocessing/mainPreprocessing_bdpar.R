source("src/pkgChecker.R")
source("src/read_csv.R")
source("src/write_csv.R")

##################################################################
##              PREPROCESSING USING BDPAR PACKAGE               ##
##################################################################

message(green("[Preprocessing][INFO] Starting preprocessing using bdpar package..."))
source("src/RedditPipes.R")
source("src/InstanceReddit.R")
source("src/RedditFactory.R")
source("src/overwritePreprocesing.R")
source("src/RedditCSVPipe.R")

bdpar_object <- Bdpar$new(configurationFilePath = "config/configurations.ini")

bdpar_object$proccess_files(filesPath = "files_input_bdpar",
                            pipe = RedditPipes$new(),
                            instanceFactory = RedditFactory$new())

files_output <- list.files(path = "files_output_bdpar/",
                           all.files = T,
                           include.dirs = F,
                           full.names = T,
                           recursive = T)

final <- data.frame()
for (file in files_output) {
  message(blue("[Preprocessing][INFO] Rbind ", file, " with all..."))
  final <- rbind(final, read_csv(file))
}

write_csv(csv = final,
          output.path = "files_output_bdpar/outPre_all_comments_september.csv")

rm(final)
rm(files_output)
rm(bdpar_object)
rm(RedditCSVPipe)
rm(RedditFactory)
rm(RedditPipes)
rm(InstanceReddit)
rm(Bdpar)

message(green("[Preprocessing][INFO] Finish preprocessing using bdpar package!"))