run_emulator <- function(options) {
    transformed_options <- transform_options(options)
    minter_params <- build_minter_params(transformed_options)

    results <- do.call(MINTer::run_mintweb_controller, minter_params)

    post_process_results(results)
}

transform_options <- function(options) {
  list(
  # baseline 
  res_use = options$pyrethroid_resistance/100,
  py_only = options$py_only/100,
  py_pbo = options$py_pbo/100,
  py_pyrrole = options$py_pyrrole/100,
  py_ppf = options$py_ppf/100,
  prev = options$current_malaria_prevalence/100,
  Q0 = options$preference_for_biting/100,
  phi = options$preference_for_biting_in_bed/100,
  season = as.integer(options$is_seasonal),
  irs = options$irs_coverage/100,
  # intervention
  itn_future = options$itn_future/100,
  net_type_future = options$itn_future_types,
  irs_future = options$irs_future/100,
  routine = as.integer(options$routine_coverage),
  lsm = options$lsm/100
 )
}

# Helper: create the baseline (no intervention) scenario
create_base_scenario <- function(options) {
  list(
    scenario_tag   = "no_intervention",
    res_use        = options$res_use,
    py_only        = options$py_only,
    py_pbo         = options$py_pbo,
    py_pyrrole     = options$py_pyrrole,
    py_ppf         = options$py_ppf,
    prev           = options$prev,
    Q0             = options$Q0,
    phi            = options$phi,
    season         = options$season,
    irs            = options$irs,
    # no intervention
    itn_future     = 0,
    net_type_future= NA_character_,
    irs_future     = 0,
    routine        = 0,
    lsm            = 0
  )
}

# Helper: override selected fields in scenario
with_overrides <- function(scenario, overrides) {
    for (field in names(overrides)) {
        scenario[[field]] <- overrides[[field]]
    }
    scenario
}
# Helper: append a scenario row to the accumulator (column-wise concat)
append_scenario <- function(accumulator, scenario) {
    Map(c, accumulator, scenario)
}

build_minter_params <- function(options) {
    base_scenario <- create_base_scenario(options)
    minter_params <- base_scenario

    # irs only
    if (options$irs_future > 0) {
        irs_only_scenario <- with_overrides(
            base_scenario,
            list(
                scenario_tag = "irs_only",
                irs_future = options$irs_future
            )
        )
        minter_params <- append_scenario(minter_params, irs_only_scenario)
    }

    # lsm only
    if (options$lsm > 0) {
        lsm_only_scenario <- with_overrides(
            base_scenario,
            list(
                scenario_tag = "lsm_only",
                lsm = options$lsm
            )
        )
        minter_params <- append_scenario(minter_params, lsm_only_scenario)
    }

    # net-type scenarios (and with lsm)
    for (net_type in options$net_type_future) {
        net_type_scenario <- with_overrides(
            base_scenario,
            list(
                scenario_tag = paste0(net_type, "_only"),
                net_type_future = net_type,
                itn_future = options$itn_future,
                routine = options$routine
            )
        )
        minter_params <- append_scenario(minter_params, net_type_scenario)

        # net with lsm
        if (options$lsm > 0) {
            net_type_lsm_scenario <- with_overrides(
                net_type_scenario,
                list(
                    scenario_tag = paste0(net_type, "_with_lsm"),
                    lsm = options$lsm
                )
            )
            minter_params <- append_scenario(minter_params, net_type_lsm_scenario)
        }
    }

    minter_params
}

post_process_results <- function(results) {
    # prevalence time steps are fortnightly
    days_in_fortnight <- 14
    days_in_year <- 365
    results$prevalence <- results$prevalence |>
        dplyr::mutate(days = row_number() * days_in_fortnight, .by = scenario)
    results$cases <- results$cases |> rename(casesPer1000 = cases_per_1000) |>
        dplyr::mutate(
            year = row_number(),
            casesPer1000 = casesPer1000 * days_in_year,
            .by = scenario
        )

    results
}