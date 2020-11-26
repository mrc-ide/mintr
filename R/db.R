mintr_db_open <- function(path, docs) {
  path_db <- mintr_db_paths(path)$db
  if (!file.exists(path_db)) {
    stop(sprintf("mintr database does not exist at '%s'", path_db))
  }
  mintr_db$new(path_db, docs)
}


mintr_db <- R6::R6Class(
  "mintr_db",
  private = list(
    index = NULL,
    ignore = NULL,
    db = NULL,
    baseline = NULL,
    docs = NULL
  ),
  public = list(
    initialize = function(path, docs) {
      private$db <- thor::mdb_env(path, readonly = TRUE, lock = FALSE,
                                  subdir = FALSE)
      private$index <- unserialize(private$db$get("index"))
      private$baseline <- setdiff(names(private$index), "index")
      private$ignore <- unserialize(private$db$get("ignore"))
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
      ret <- unserialize(private$db$get(sprintf("prevalence:%s", key)))
      mintr_db_transform_metabolic(ret, options$metabolic)
    },

    get_impact_docs = function() {
      private$docs$impact
    },

    get_cost_docs = function() {
      private$docs$cost
    },

    get_table = function(options) {
      key <- self$get_index(options)
      ret <- unserialize(private$db$get(sprintf("table:%s", key)))
      ret$casesAverted <- round(ret$casesAverted * options$population)
      mintr_db_transform_metabolic(ret, options$metabolic)
    }
  ))


## Some constants that crop up everywhere
mintr_db_paths <- function(path) {
  list(db = file.path(path, "mintr.db"),
       db_lock = file.path(path, "mintr.db-lock"),
       index = file.path(path, "index.rds"),
       prevalence = file.path(path, "prevalence.rds"),
       table = file.path(path, "table.rds"))
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
        if (control$type == "select" && control$name != "metabolic") {
          index[[control$name]] <- vcapply(control$options, "[[", "id")
        } else {
          ignore <- c(ignore, control$name)
        }
      }
    }
  }
  list(index = index, ignore = ignore)
}


mintr_db_check_index <- function(index) {
  baseline <- mint_baseline_options()
  assert_setequal(names(index), c(names(baseline$index), "index"))
  for (i in names(baseline$index)) {
    assert_setequal(index[[i]], baseline$index[[i]], sprintf("index$%s", i))
  }
  baseline$ignore
}


mintr_db_check_prevalence <- function(index, prevalence) {
  cols <- c("month", "value", "netUse", "irsUse", "netType", "intervention",
            "index")
  assert_setequal(names(prevalence), cols)
  assert_setequal(prevalence$index, index$index)

  expected <- mint_intervention(
    prevalence$netUse, prevalence$irsUse, prevalence$netType)
  if (!identical(expected, prevalence$intervention)) {
    stop("Interventions do not match expected values")
  }
}


mint_intervention <- function(net_use, irs_use, net_type) {
  intervention <- c(# net_use  irs_use  net_type
    "none",         # == 0     == 0     == std
    "llin",         #  > 0     == 0     == std
    "irs",          # == 0      > 0     == std
    "irs-llin",     #  > 0      > 0     == std
    "none",         # == 0     == 0     == pto
    "llin-pbo",     #  > 0     == 0     == pto
    "irs",          # == 0      > 0     == pto
    "irs-llin-pbo") #  > 0      > 0     == pto

  ## Use bit packing to get the above relationship:
  i <- (net_use > 0) + (irs_use > 0) * 2 + (net_type == "pto") * 4 + 1
  intervention[i]
}


## The metabolic switch controls the effect of the pbo net
## synergy. When not used (metabolic as "no"), then we basically just
## over-write the values for PBO interventions with non-PBO
## interventions. This means that `llin-pbo` is set the same as for
## `llin` (and similarly for `irs-llin-pbo`/`irs-llin`).
mintr_db_transform_metabolic <- function(d, metabolic) {
  if (metabolic == "no") {
    cols <- setdiff(names(d), "intervention")
    for (intervention in c("llin-pbo", "irs-llin-pbo")) {
      i_dest <- d$intervention == intervention
      i_src <- d$intervention == sub("-pbo$", "", intervention)
      stopifnot(sum(i_dest) == sum(i_src))
      d[i_dest, cols] <- d[i_src, cols]
    }
  }
  d
}
