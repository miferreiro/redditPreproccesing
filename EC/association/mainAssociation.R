source("pkgChecker.R")
data.frame.dtm <- readRDS(file = "../preprocessing/files_output_tm/data_frame_dtm_final.rds")

message(green("[INFO] Starting association"))
train <- sapply(data.frame.dtm, as.factor)
train <- data.frame(train, check.names=FALSE)
df.rules <- as(train,"transactions")
# image(df.rules)
# saveRDS(df.rules, "EC/R/association/saveFilesRDS/df-rulesv1.rds")

# La generación de reglas se realiza fijando:
# Soporte: Proporción de transacciones en la base de datos que contiene cada conjunto de items.
# Confianza: Porcentaje de veces que se cumple la regla en la que se encuentran los items.
# rules <- apriori(df.rules,
#                  parameter = list(support = 0.9, confidence = 0.9, minlen = 3, maxlen = 10, target = "rules", maxtime=300),
#                  control = list(verbose = T, memopt = T, sort = -1))
#
# inspect(rules)
# # rules_unique <- rules[-which(colSums(is.subset(rules, rules)) > 1)]
#
#
# saveRDS(rules, "EC/R/association/saveFilesRDS/rulesv1.rds")
#
# #
# rules_lift <- sort(rules, by = "lift", decreasing = TRUE)
# top10subRules <- head(rules, n = 10, by = "confidence")
# plot(top10subRules, method = "graph",engine = "htmlwidget")

message(green("[INFO] Starting fpgrowth"))

rules = rCBA::fpgrowth(df.rules, support = 1, confidence = 1,
                       maxLength = 3,
                       consequent = "nameOfSubreddit", parallel=FALSE)
message(green("[INFO] Starting classification"))
predictions <- rCBA::classification(train, rules)
table(predictions)
print(sum(as.character(train$nameOfSubreddit) == as.character(predictions), na.rm=TRUE)/length(predictions))
message(green("[INFO] Starting pruning"))
prunedRules <- rCBA::pruning(train, rules, method="m2cba", parallel=FALSE)
message(green("[INFO] Starting classification"))
predictions <- rCBA::classification(train, prunedRules)
table(predictions)

print(sum(as.character(train$nameOfSubreddit) == as.character(predictions),na.rm=TRUE)/length(predictions))
