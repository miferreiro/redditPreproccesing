source("src/pkgChecker.R")
source("src/write_csv.R")
source("src/read_csv.R")

message(green("[Collecting][INFO] Starting collecting..."))
source("src/getComments.R")

#Start process to collect the comments from the subreddits indicated
getComments(subreddits = c("Fitness", "loseit", "bodybuilding", "xxfitness", "nutrition"),
            start.date = as.numeric(as.POSIXlt(x = "2019-09-01 00:00:00", tz = "CET")),
            end.date = as.numeric(as.POSIXlt(x = "2019-09-30 00:00:00", tz = "CET")),
            num.comments = 1000)
rm(getComments)
rm(non_recs)
#Start process to clean the content of some fields
source("src/comments.R")
suppressWarnings(cleanComments())
rm(cleanComments)
message(green("[Collecting][INFO] Finish collecting!"))
