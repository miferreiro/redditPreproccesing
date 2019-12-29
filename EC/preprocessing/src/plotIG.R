library(dplyr)
ig <- readRDS(file = "files_output_IG/result_ig_without_stem.rds")
ig <- as.data.frame(ig,stringsAsFactors = F)
ig[] <- lapply(ig, as.numeric)
colnames(ig) <- "attr_importance"
ig <- arrange(ig,-attr_importance)
plot(type = "l", density(ig$attr_importance), xlim=c(0,0.001),main = "Information gain", xlab = "importance", ylab = "Density")
cut.off.ig = 10000
abline(v = ig$attr_importance[cut.off.ig], col = "red", lty = 2)

density <- density(ig$attr_importance)
min <- min(which(density$x >= ig$attr_importance[cut.off.ig]))
max <- max(which(density$x <= ig$attr_importance[1]))
with(density, polygon(x = c(x[c(min, min:max, max)]), y = c(0,y[min:max], 0), col = rgb(0, 206/255, 209/255, 0.5)))


