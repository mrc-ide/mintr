Sys.setenv(PORCELAIN_VALIDATE = "true")

mintr_test_db <- function() {
  mintr_db_open("data", get_compiled_docs())
}

## Somewhat friendly initialisation script for CI
mintr_test_db_init <- function() {
  path <- file.path("data", mintr_data_version())
  if (!file.exists(mintr_db_paths(path)$index)) {
    mintr_db_download("data")
  }
}

create_strategise_test_data <- function() {
  json_txt <- '{
  "maxCost": 10000,
  "minCost": 1000,
  "regions": [
    {"region": "Region A", "interventions": [
      {"intervention": "lsm_only", "cost": 1000, "casesAverted": 50}
    ]},
    {"region": "Region B", "interventions": [
      {"intervention": "irs_only", "cost": 1500, "casesAverted": 70},
      {"intervention": "lsm_only", "cost": 2500, "casesAverted": 150},
      {"intervention": "py_only", "cost": 3000, "casesAverted": 200}
    ]},
    {"region": "Region C", "interventions": [
      {"intervention": "irs_only", "cost": 2000, "casesAverted": 80},
      {"intervention": "lsm_only", "cost": 3000, "casesAverted": 160},
      {"intervention": "py_only", "cost": 3500, "casesAverted": 220},
      {"intervention": "py_pbo_with_lsm", "cost": 4500, "casesAverted": 320}
    ]}
  ]
}'
  jsonlite::fromJSON(json_txt, flatten = TRUE, simplifyVector = TRUE)
}

