read_csv = function(csv) {
  message(blue("[Wordcloud][INFO] Reading csv from", csv))
  read.csv(file = csv,
           header = TRUE,
           sep = ";",
           dec = ".",
           fill = FALSE,
           stringsAsFactors = FALSE,
           encoding = "UTF-8")
}