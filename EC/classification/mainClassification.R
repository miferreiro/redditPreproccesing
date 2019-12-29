source("src/pkgChecker.R")
message(green("[Classification][INFO] Starting classification..."))
set.seed(100)

# data.frame.dtm <- readRDS("files_input/data_frame_dtm_final.rds")
data.frame.dtm <- readRDS("../preprocessing/files_output_IG/result_ig_data_frame_dtm_without_stem.rds")
target <- data.frame.dtm$nameOfSubreddit
authors <- data.frame.dtm$authorComment
data.frame.dtm[] <- lapply(data.frame.dtm, as.numeric)
data.frame.dtm$nameOfSubreddit <- as.factor(target)
data.frame.dtm$authorComment <- as.factor(authors)
def.formula <- as.formula("nameOfSubreddit~.")

index <- caret::createDataPartition(data.frame.dtm$nameOfSubreddit, p = .75, list = FALSE)
train <- data.frame.dtm[index, ]
test <-  data.frame.dtm[-index, ]

rec <- recipes::recipe(formula = def.formula, data = train) %>%
  recipes::step_zv(all_predictors())   #%>% #remove zero variance
  # recipes::step_nzv(recipes::all_predictors()) %>% #remove near-zero variance
  # recipes::step_corr(recipes::all_predictors()) #remove high correlation filter.


trControl <- caret::trainControl(method = "cv", #use cross-validation
                                 number = 10, #divide cross-validation into 10 folds
                                 search = "random", #"grid"
                                 savePredictions = "final", #save predictions of best model.
                                 #classProbs = TRUE, #save probabilities obtained for the best model.
                                 summaryFunction = caret::defaultSummary, #use defaultSummary function (only computes Accuracy and Kappa values)
                                 allowParallel = TRUE, #execute in parallel.
                                 seeds = set.seed(100))
message(blue("[Classification][INFO] Starting training..."))
trained <- caret::train(rec,
                        data = train,
                        method = "rf",
                        trControl = trControl,
                        metric = "Accuracy")

saveRDS(trained, file = "trained/trained_nb.rds")
message(blue("[Classification][INFO] Starting testing..."))
cf <- caret::confusionMatrix(
  predict(trained, newdata = test, type = "raw"),
  reference = test$nameOfSubreddit
)

saveRDS(cf, file = "confusionMatrix/cf.rds")

message(green("[Classification][INFO] Finish classification!"))

# source("src/draw_confusion_matrix.R")
# draw_confusion_matrix(cf, paste("Confusion Matrix Naive-Bayes",class,sep = " "))