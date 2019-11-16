write_csv = function(csv, output.path, append = FALSE) {
  write.table(x = csv,
              file = output.path,
              append = append,
              sep = ";",
              dec = ".",
              quote = TRUE,
              col.names = !file.exists(output.path),
              row.names = FALSE,
              qmethod = c("double"),
              fileEncoding = "UTF-8",
              na = "NULL")
}