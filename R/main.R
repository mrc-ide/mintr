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
  db <- mintr_db_open(opts$data)
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
