main_args <- function(args = commandArgs(TRUE)) {
  usage <- "Usage:
  mintr [options]

Options:
  --port=PORT   Port to run on [default: 8888]
  --data=PATH   Path to the mintr data [default: data]"
  dat <- docopt::docopt(usage, args)
  list(port = as.integer(dat$port), data = dat$data)
}


main <- function(args = commandArgs(TRUE)) {
  opts <- main_args(args)
  port <- opts$port
  ## This is primarily run from the docker container, where we need to
  ## import the data from the processed .rds files into the database,
  ## ready for the API.
  message("Importing data")
  mintr_db_import(opts$data)
  message("Opening database")
  db <- mintr_db_open(opts$data)
  message("Starting API")
  api_run(port, db)
}


write_script <- function(dest) {
  dir.create(dest, FALSE, TRUE)
  code <- "#!/usr/bin/env Rscript\nmintr:::main()"
  path <- file.path(dest, "mintr")
  writeLines(code, path)
  Sys.chmod(path, "0755")
  invisible(path)
}
