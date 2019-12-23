write_csv = function(csv,
                     output.path,
                     append = FALSE,
                     col.names = !file.exists(output.path)) {
  write.table(x = csv,
              file = output.path,
              append = append,
              sep = ";",
              dec = ".",
              quote = TRUE,
              col.names = col.names,
              row.names = FALSE,
              qmethod = c("double"),
              fileEncoding = "UTF-8",
              na = "NULL")
}