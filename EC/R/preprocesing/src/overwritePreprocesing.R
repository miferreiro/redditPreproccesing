Bdpar$proccess_files <- function(filesPath,
                                 pipe = SerialPipe$new(),
                                 instanceFactory = InstanceFactory$new()) {

  if (!"character" %in% class(filesPath)) {
    stop("[Bdpar][proccess_files][Error] Checking the type of the variable: filesPath ", class(filesPath))
  }
  if (!"TypePipe" %in% class(pipe)) {
    stop("[Bdpar][proccess_files][Error] Checking the type of the variable: pipe ", class(pipe))
  }
  if (!"InstanceFactory" %in% class(instanceFactory)) {
    stop("[Bdpar][proccess_files][Error] Checking the type of the variable: instanceFactory ", class(instanceFactory))
  }

  Files <- list.files(path = filesPath, recursive = TRUE, full.names = TRUE, all.files = TRUE)
  InstancesList <- sapply(Files, instanceFactory$createInstance)
  message("[Bdpar][proccess_files][Info] ", "Has been created: ", length(unlist(InstancesList))," instances.\n")
  listInstances <- sapply(InstancesList, pipe$pipeAll)

  return(listInstances)
}