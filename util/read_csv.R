read_csv = function(csv) {
  message(green("[INFO] Reading csv from", csv))
  read.csv(file = csv,header = TRUE,sep = ";",dec = ".",fill = FALSE,stringsAsFactors = FALSE)
}