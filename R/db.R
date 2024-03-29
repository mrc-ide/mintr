mintr_db_open <- function(path, docs = get_compiled_docs()) {
  paths <- mintr_db_paths(file.path(path, mintr_data_version()))
  if (!file.exists(paths$index)) {
    stop(sprintf("mintr database does not exist at '%s'", paths$index))
  }
  mintr_db$new(paths, docs)
}


mintr_db <- R6::R6Class(
  "mintr_db",
  private = list(
    path = NULL,
    index = NULL,
    ignore = NULL,
    db = NULL,
    baseline = NULL,
    docs = NULL
  ),
  public = list(
    initialize = function(path, docs) {
      private$path <- path
      private$index <- readRDS(path$index)
      private$baseline <- setdiff(names(private$index), "index")
      private$ignore <- readRDS(path$ignore)
      private$docs <- docs
    },

    get_index = function(options) {
      nms <- setdiff(names(options), private$ignore)
      assert_setequal(nms, private$baseline, "names(options)")
      valid <- rep(TRUE, nrow(private$index))
      for (i in nms) {
        valid <- valid & options[[i]] == private$index[[i]]
        if (!any(valid)) {
          stop(sprintf("No matching value '%s' for option '%s'",
                       options[[i]], i))
        }
      }
      stopifnot(sum(valid) == 1L) # this will always be true
      private$index$index[valid]
    },

    get_prevalence = function(options) {
      key <- self$get_index(options)
      p <- sprintf(private$path$prevalence, key)
      ret <- readRDS(p)
      filtered <- mintr_db_filter_to_3_years_post_intervention(ret)
      mintr_db_set_not_applicable_values(filtered)
    },

    get_impact_docs = function() {
      private$docs$impact
    },

    get_cost_docs = function() {
      private$docs$cost
    },

    get_table = function(options) {
      key <- self$get_index(options)
      p <- sprintf(private$path$table, key)
      ret <- readRDS(p)
      to_round <- c("casesAverted", "casesAvertedErrorMinus",
                    "casesAvertedErrorPlus")
      for (v in to_round) {
        ret[[v]] <- round(ret[[v]] * options$population)
      }

      # Sort by sensible intervention ordering
      ordering <- c("none", "llin", "llin-pbo", "pyrrole-pbo", "irs", "irs-llin", "irs-llin-pbo", "irs-pyrrole-pbo")
      sorted  <- ret[order(match(ret$intervention, ordering)), ]
      
      mintr_db_set_not_applicable_values(sorted)
    }
  ))


## Some constants that crop up everywhere
mintr_db_paths <- function(path) {
  list(hash = file.path(path, "hash.rds"),
       index = file.path(path, "index.rds"),
       ignore = file.path(path, "ignore.rds"),
       table = file.path(path, "table", "%s.rds"),
       prevalence = file.path(path, "prevalence", "%s.rds"))
}


## We should do this both on writing to the db and on reading to it?
mint_baseline_options <- function() {
  path <- mintr_path("json/baseline_options.json")
  baseline <- jsonlite::fromJSON(path, FALSE)
  index <- list()
  ignore <- character(0)
  for (section in baseline$controlSections) {
    for (group in section$controlGroups) {
      for (control in group$controls) {
        if (control$type == "select") {
          index[[control$name]] <- vcapply(control$options, "[[", "id")
        } else {
          ignore <- c(ignore, control$name)
        }
      }
    }
  }
  list(index = index, ignore = ignore)
}


mint_intervention <- function(net_use, irs_use, net_type) {
  intervention <- c(# net_use  irs_use  net_type
    ## Standard
    "none",            # == 0     == 0     == std
    "llin",            #  > 0     == 0     == std
    "irs",             # == 0      > 0     == std
    "irs-llin",        #  > 0      > 0     == std
    ## PTO
    "none",            # == 0     == 0     == pto
    "llin-pbo",        #  > 0     == 0     == pto
    "irs",             # == 0      > 0     == pto
    "irs-llin-pbo",    #  > 0      > 0     == pto
    ## The Third Net
    "none",            # == 0     == 0     == ig2
    "pyrrole-pbo",     #  > 0     == 0     == ig2
    "irs",             # == 0      > 0     == ig2
    "irs-pyrrole-pbo") #  > 0      > 0     == ig2

  ## Use bit packing to get the above relationship:
  i <- 1 + (net_use > 0) +
    (irs_use > 0) * 2 +
    (net_type == "pto") * 4 +
    (net_type == "ig2") * 8
  intervention[i]
}

# Rather than the relationship between series and settings
# decribed in the mint_intervention function, the front-end
# requires data that adheres to:
#intervention         net_use  irs_use
#  "none"            == n/a    == n/a
#  "llin"            >= 0      == n/a
#  "irs"             == n/a    >= 0
#  "irs-llin"        >= 0      >= 0
#  "llin-pbo"        >= 0      == n/a
#  "pyrrole-pbo"     >= 0      == n/a  
#  "irs"             == n/a    >= 0
#  "irs-llin-pbo"    >= 0      >= 0
#  "irs-pyrrole-pbo" >= 0      >= 0
#
mintr_db_set_not_applicable_values <- function(data) {
  # this special value is used by the front-end to display
  # series for which a chosen setting doesn't apply but the user
  # nevertheless wants to see a comparison against
  not_applicable <- "n/a"
  data[data$intervention %in% c("llin", "llin-pbo", "pyrrole-pbo"), ]$irsUse <- not_applicable
  data[data$intervention =="irs", ]$netUse <- not_applicable
  data[data$intervention =="none", ]$netUse <- not_applicable
  data[data$intervention =="none", ]$irsUse <- not_applicable
  data
}

# The prevalence graph data in the database goes up to 4 years post-intervention
# but we only actually want to display 3 years
mintr_db_filter_to_3_years_post_intervention <- function(data) {
  data[data$month <= 36, ]
}
