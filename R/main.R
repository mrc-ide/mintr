main_args <- function(args = commandArgs(TRUE)) {
  usage <- "Usage:
  mintr [options]

Options:
  --port=PORT       Port to run on [default: 8888]
  --data=PATH       Path to the mintr data [default: data]
  --emulator=PATH   Path to emulator configuration and models"
  dat <- docopt::docopt(usage, args)
  list(port = as.integer(dat$port), data = dat$data, emulator_root=dat$emulator)
}


main <- function(args = commandArgs(TRUE)) {
  opts <- main_args(args)
  port <- opts$port
  message("Compiling docs")
  docs <- get_compiled_docs()
  message("Opening database")
  db <- mintr_db_open(opts$data, docs)
  message("Starting API")
  api_run(port, db, opts$emulator_root)
}


get_compiled_docs <- function() {
  impact <- readLines(mintr_path("json/impact_docs.md"))
  impact_compiled <- commonmark::markdown_html(impact)
  cost <- readLines(mintr_path("json/cost_docs.md"))
  cost_compiled <- commonmark::markdown_html(cost)
  docs <- list(impact = html_string_as_json(impact_compiled), cost = html_string_as_json(cost_compiled))
}


write_script <- function(dest) {
  dir.create(dest, FALSE, TRUE)
  code <- "#!/usr/bin/env Rscript\nmintr:::main()"
  path <- file.path(dest, "mintr")
  writeLines(code, path)
  Sys.chmod(path, "0755")
  invisible(path)
}
