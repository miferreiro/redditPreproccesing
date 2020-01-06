source("src/pkgChecker.R")
message(green("[Classification][INFO] Starting classification..."))
set.seed(123)

tfidf <- T
# subsampling <- "all_train"
# subsampling <- "down_sample_train"
subsampling <- "smote_train"

onlyTrain  <- FALSE
if (!onlyTrain)  {
if (tfidf) {
  message(blue("[Classification][INFO] tfidf"))
  data.frame.dtm <- readRDS("files_input/out_tfidf_data_frame_IG.rds")
} else {
  data.frame.dtm <- readRDS("files_input/out_data_frame_IG.rds")
}

target <- data.frame.dtm$nameOfSubreddit
authors <- data.frame.dtm$authorComment
data.frame.dtm[] <- lapply(data.frame.dtm, as.numeric)
data.frame.dtm$nameOfSubreddit <- as.factor(target)
# data.frame.dtm$authorComment <- as.factor(authors)
def.formula <- as.formula("nameOfSubreddit~.")
rm(target)
rm(authors)

#################################################################
##                Selecting train and test data                ##
#################################################################

set.seed(123)
index <- caret::createDataPartition(data.frame.dtm$nameOfSubreddit, p = .75, list = FALSE)
train <- data.frame.dtm[index, ]
test <-  data.frame.dtm[-index, ]

if (subsampling == "all_train") {
  message(blue("[Classification][INFO] all_train"))
  if (tfidf) {
    message(blue("[Classification][INFO] tfidf"))
    saveRDS(list(train = train, test = test), "./tfidf_all_train.rds")
  } else {
    message(blue("[Classification][INFO] bag of words"))
    saveRDS(list(train = train, test = test), "./all_train.rds")
  }
} else {
  if (subsampling == "down_sample_train") {
    message(blue("[Classification][INFO] down_sample_train"))
    set.seed(123)
    down_sample_train <- downSample(train, train$nameOfSubreddit)
    down_sample_train$Class <- NULL
    if (tfidf) {
      message(blue("[Classification][INFO] tfidf"))
      saveRDS(list(train = down_sample_train, test = test), "./tfidf_down_sample_train.rds")
    } else {
      message(blue("[Classification][INFO] bag of words"))
      saveRDS(list(train = down_sample_train, test = test), "./down_sample_train.rds")
    }
  } else {
    if (subsampling == "smote_train") {
      message(blue("[Classification][INFO] smote_train"))
      set.seed(123)
      smote_train <- DMwR::SMOTE(def.formula, data  = train)
      smote_train$Class <- NULL
      if (tfidf) {
        message(blue("[Classification][INFO] tfidf"))
        saveRDS(list(train = smote_train, test = test), "./tfidf_smote_train.rds")
      } else {
        message(blue("[Classification][INFO] bag of words"))
        saveRDS(list(train = smote_train, test = test), "./smote_train.rds")
      }
    } else {
      stop("Incorrect subsampling method")
    }
  }
}
}
stop("aqui")

if (subsampling == "all_train") {
  message(blue("[Classification][INFO] all_train"))
  if (tfidf) {
    message(blue("[Classification][INFO] tfidf"))
    trainTest <- readRDS("./tfidf_all_train.rds")
  } else {
    message(blue("[Classification][INFO] bag of words"))
    trainTest <- readRDS("./all_train.rds")
  }
} else {
  if (subsampling == "down_sample_train") {
    message(blue("[Classification][INFO] down_sample_train"))
    if (tfidf) {
      message(blue("[Classification][INFO] tfidf"))
      trainTest <- readRDS("./tfidf_down_sample_train.rds")
    } else {
      message(blue("[Classification][INFO] bag of words"))
      trainTest <- readRDS("./down_sample_train.rds")
    }
  } else {
    if (subsampling == "smote_train") {
      message(blue("[Classification][INFO] smote_train"))
       if (tfidf) {
         message(blue("[Classification][INFO] tfidf"))
         trainTest <- readRDS("./tfidf_smote_train.rds")
       } else {
         message(blue("[Classification][INFO] bag of words"))
         trainTest <- readRDS("./smote_train.rds")
       }
    } else {
      stop("Incorrect subsampling method")
    }
  }
}

train <- trainTest$train
test <- trainTest$test

##################################################################
##                        CLASSIFICATION                        ##
##################################################################

rec <- recipes::recipe(formula = def.formula, data = train) %>%
         recipes::step_zv(all_predictors()) %>% #remove zero variance
           recipes::step_nzv(all_predictors()) %>% #remove near-zero variance
              recipes::step_corr(all_predictors()) #remove high correlation filter.

trControl <- caret::trainControl(method = "cv", #use cross-validation
                                 number = 10, #divide cross-validation into 10 folds
                                 search = "random", #"grid"
                                 savePredictions = "final", #save predictions of best model.
                                 classProbs = TRUE, #save probabilities obtained for the best model.
                                 # summaryFunction = caret::defaultSummary, #use defaultSummary function (only computes Accuracy and Kappa values)
                                 summaryFunction = caret::multiClassSummary,
                                 allowParallel = TRUE, #execute in parallel.
                                 seeds = set.seed(100))

message(blue("[Classification][INFO] Starting training..."))

method <- "OneR"
# method <- "naive_bayes"
# method <- "J48"
# method <- "svmLinear2"
# method <- "svmLinear3"
# method <- "rpart"
# method <- "rpart2"

set.seed(123)
trained <- caret::train(rec,
                        data = train,
                        method = method,
                        trControl = trControl,
                        metric = "Accuracy")
if (tfidf) {
  message(blue("[Classification][INFO] tfidf"))
  saveRDS(trained, file = paste0("files_output/", subsampling, "_tfidf_trained_", method, ".rds"))
} else {
  message(blue("[Classification][INFO] bag of words"))
  saveRDS(trained, file = paste0("files_output/", subsampling, "_trained_", method, ".rds"))
}

message(blue("[Classification][INFO] Starting testing..."))

set.seed(123)
cf <- caret::confusionMatrix(
  predict(trained, newdata = test, type = "raw"),
  reference = test$nameOfSubreddit
)

# cf$byClass

if (tfidf) {
  message(blue("[Classification][INFO] tfidf"))
  saveRDS(cf, file = paste0("files_output/", subsampling, "_tfidf_cf_", method, ".rds"))
} else {
  message(blue("[Classification][INFO] bag of words"))
  saveRDS(cf, file = paste0("files_output/", subsampling, "_cf_", method, ".rds"))
}

message(green("[Classification][INFO] Finish classification!"))
