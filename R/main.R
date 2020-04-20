main_args <- function(args = commandArgs()) {
  usage <- "Usage:
  mintr [options]

Options:
  --port=PORT   Port to run on [default: 8888]"
  dat <- docopt::docopt(usage, args)
  list(port = as.integer(dat$port))
}


main <- function(args = commandArgs()) {
  opts <- main_args(args)
  port <- opts$port
  api_run(port)
}
