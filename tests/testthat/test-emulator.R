
# Test data setup
create_test_options <- function() {
    list(
        pyrethroid_resistance = 50,
        py_only = 30,
        py_pbo = 20,
        py_pyrrole = 10,
        py_ppf = 5,
        current_malaria_prevalence = 15,
        preference_for_biting = 25,
        preference_for_biting_in_bed = 35,
        is_seasonal = TRUE,
        irs_coverage = 40,
        # interventions
        itn_future = 45,
        itn_future_types = c("py_only", "py_pbo"),
        irs_future = 50,
        routine_coverage = TRUE,
        lsm = 60
    )
}

test_that("transform_options correctly transforms form options", {
    options <- create_test_options()
    result <- transform_options(options)
    
    # Test percentage conversions
    expect_equal(result$res_use, 0.5)
    expect_equal(result$py_only, 0.3)
    expect_equal(result$py_pbo, 0.2)
    expect_equal(result$py_pyrrole, 0.1)
    expect_equal(result$py_ppf, 0.05)
    expect_equal(result$prev, 0.15)
    expect_equal(result$Q0, 0.25)
    expect_equal(result$phi, 0.35)
    expect_equal(result$irs, 0.4)
    expect_equal(result$itn_future, 0.45)
    expect_equal(result$irs_future, 0.5)
    expect_equal(result$lsm, 0.6)
    
    # Test type conversions
    expect_equal(result$season, 1L)
    expect_equal(result$routine, 1L)
    
    # Test direct assignments
    expect_equal(result$net_type_future, c("py_only", "py_pbo"))
})

test_that("transform_options handles FALSE boolean values", {
    options <- create_test_options()
    options$is_seasonal <- FALSE
    options$routine_coverage <- FALSE
    
    result <- transform_options(options)
    
    expect_equal(result$season, 0L)
    expect_equal(result$routine, 0L)
})

test_that("create_base_scenario creates correct baseline scenario", {
    transformed_options <- list(
        res_use = 0.5, py_only = 0.3, py_pbo = 0.2, py_pyrrole = 0.1,
        py_ppf = 0.05, prev = 0.15, Q0 = 0.25, phi = 0.35,
        season = 1L, irs = 0.4, itn_future = 0.45,
        net_type_future = c("py_only", "py_pbo"), irs_future = 0.5,
        routine = 1L, lsm = 0.6
    )
    
    result <- create_base_scenario(transformed_options)
    
    expect_equal(result$scenario_tag, "no_intervention")
    expect_equal(result$res_use, 0.5)
    expect_equal(result$py_only, 0.3)
    expect_equal(result$prev, 0.15)
    expect_equal(result$irs, 0.4)
    
    # Check interventions are set to zero/NA
    expect_equal(result$itn_future, 0)
    expect_true(is.na(result$net_type_future))
    expect_equal(result$irs_future, 0)
    expect_equal(result$routine, 0)
    expect_equal(result$lsm, 0)
})


test_that("with_overrides correctly updates scenario fields", {
    base_scenario <- list(
        scenario_tag = "base",
        field1 = 10,
        field2 = "original",
        field3 = TRUE
    )
    
    overrides <- list(
        scenario_tag = "updated",
        field2 = "modified",
        field4 = 42
    )
    
    result <- with_overrides(base_scenario, overrides)
    
    expect_equal(result$scenario_tag, "updated")
    expect_equal(result$field1, 10)  # unchanged
    expect_equal(result$field2, "modified")
    expect_equal(result$field3, TRUE)  # unchanged
    expect_equal(result$field4, 42)  # new field
})

test_that("append_scenario correctly concatenates scenarios column-wise", {
    accumulator <- list(
        field1 = c(1, 2),
        field2 = c("a", "b"),
        field3 = c(TRUE, FALSE)
    )
    
    new_scenario <- list(
        field1 = 3,
        field2 = "c",
        field3 = TRUE
    )
    
    result <- append_scenario(accumulator, new_scenario)
    
    expect_equal(result$field1, c(1, 2, 3))
    expect_equal(result$field2, c("a", "b", "c"))
    expect_equal(result$field3, c(TRUE, FALSE, TRUE))
})

test_that("build_minter_params creates baseline scenario only when no interventions", {
    options <- list(
        res_use = 0.5, py_only = 0.3, py_pbo = 0.2, py_pyrrole = 0.1,
        py_ppf = 0.05, prev = 0.15, Q0 = 0.25, phi = 0.35,
        season = 1L, irs = 0.4, itn_future = 0.45,
        net_type_future = character(0), irs_future = 0, routine = 0L, lsm = 0
    )
    
    result <- build_minter_params(options)
    
    expect_equal(result$scenario_tag, "no_intervention")
    expect_equal(length(result$scenario_tag), 1)
})

test_that("build_minter_params adds IRS scenario when irs_future > 0", {
    options <- list(
        res_use = 0.5, py_only = 0.3, py_pbo = 0.2, py_pyrrole = 0.1,
        py_ppf = 0.05, prev = 0.15, Q0 = 0.25, phi = 0.35,
        season = 1L, irs = 0.4, itn_future = 0.45,
        net_type_future = character(0), irs_future = 0.6, routine = 0L, lsm = 0
    )
    
    result <- build_minter_params(options)
    
    expect_equal(result$scenario_tag, c("no_intervention", "irs_only"))
    expect_equal(result$irs_future, c(0, 0.6))
})

test_that("build_minter_params adds LSM scenario when lsm > 0", {
    options <- list(
        res_use = 0.5, py_only = 0.3, py_pbo = 0.2, py_pyrrole = 0.1,
        py_ppf = 0.05, prev = 0.15, Q0 = 0.25, phi = 0.35,
        season = 1L, irs = 0.4, itn_future = 0.45,
        net_type_future = character(0), irs_future = 0, routine = 0L, lsm = 0.3
    )
    
    result <- build_minter_params(options)
    
    expect_equal(result$scenario_tag, c("no_intervention", "lsm_only"))
    expect_equal(result$lsm, c(0, 0.3))
})

test_that("build_minter_params adds net type scenarios", {
    options <- list(
        res_use = 0.5, py_only = 0.3, py_pbo = 0.2, py_pyrrole = 0.1,
        py_ppf = 0.05, prev = 0.15, Q0 = 0.25, phi = 0.35,
        season = 1L, irs = 0.4, itn_future = 0.45,
        net_type_future = c("py_only", "py_pbo"), irs_future = 0, 
        routine = 1L, lsm = 0
    )
    
    result <- build_minter_params(options)
    
    expected_tags <- c("no_intervention", "py_only_only", "py_pbo_only")
    expect_equal(result$scenario_tag, expected_tags)
    expect_equal(result$net_type_future, c(NA_character_, "py_only", "py_pbo"))
    expect_equal(result$itn_future, c(0, 0.45, 0.45))
})

test_that("build_minter_params adds net type with LSM scenarios", {
    options <- list(
        res_use = 0.5, py_only = 0.3, py_pbo = 0.2, py_pyrrole = 0.1,
        py_ppf = 0.05, prev = 0.15, Q0 = 0.25, phi = 0.35,
        season = 1L, irs = 0.4, itn_future = 0.45,
        net_type_future = c("py_only"), irs_future = 0, 
        routine = 1L, lsm = 0.3
    )
    
    result <- build_minter_params(options)
    
    expected_tags <- c("no_intervention", "lsm_only", "py_only_only", "py_only_with_lsm")
    expect_equal(result$scenario_tag, expected_tags)
    expect_equal(result$lsm, c(0, 0.3, 0, 0.3))
})

test_that("build_minter_params handles complex scenario combinations", {
    options <- list(
        res_use = 0.5, py_only = 0.3, py_pbo = 0.2, py_pyrrole = 0.1,
        py_ppf = 0.05, prev = 0.15, Q0 = 0.25, phi = 0.35,
        season = 1L, irs = 0.4, itn_future = 0.45,
        net_type_future = c("py_only", "py_pbo"), irs_future = 0.6, 
        routine = 1L, lsm = 0.3
    )
    
    result <- build_minter_params(options)
    
    expected_tags <- c("no_intervention", "irs_only", "lsm_only", 
                       "py_only_only", "py_only_with_lsm",
                       "py_pbo_only", "py_pbo_with_lsm")
    expect_equal(result$scenario_tag, expected_tags)
    expect_equal(length(result$scenario_tag), 7)
})
