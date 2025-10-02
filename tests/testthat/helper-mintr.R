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
  "budget": 10000,
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
json_txt <- '{
  "budget": 0,
  "regions": [
    {
      "region": "china",
      "interventions": [
        {
          "intervention": "irs_only",
          "cost": 150000,
          "casesAverted": 1479.7480000000003
        },
        {
          "intervention": "lsm_only",
          "cost": 50000,
          "casesAverted": 9237.368
        },
        {
          "intervention": "py_ppf_only",
          "cost": 53390.02777777778,
          "casesAverted": -212.3769999999996
        },
        {
          "intervention": "py_ppf_with_lsm",
          "cost": 103390.02777777778,
          "casesAverted": 1278.51
        },
        {
          "intervention": "py_pyrrole_only",
          "cost": 51339.19444444444,
          "casesAverted": -387.3860000000002
        },
        {
          "intervention": "py_pyrrole_with_lsm",
          "cost": 101339.19444444444,
          "casesAverted": 1191.386
        },
        {
          "intervention": "py_pbo_only",
          "cost": 48468.02777777778,
          "casesAverted": -397.27300000000014
        },
        {
          "intervention": "py_pbo_with_lsm",
          "cost": 98468.02777777778,
          "casesAverted": 1086.107
        },
        {
          "intervention": "py_only_only",
          "cost": 46485.55555555556,
          "casesAverted": -368.14099999999996
        },
        {
          "intervention": "py_only_with_lsm",
          "cost": 96485.55555555556,
          "casesAverted": 1112.2930000000001
        }
      ]
    },
    {
      "region": "inida",
      "interventions": [
        {
          "intervention": "irs_only",
          "cost": 750000,
          "casesAverted": 21227.024999999998
        },
        {
          "intervention": "lsm_only",
          "cost": 250000,
          "casesAverted": 38711.195
        }
      ]
    },
    {
      "region": "australia",
      "interventions": [
        {
          "intervention": "lsm_only",
          "cost": 225000,
          "casesAverted": 15132.572999999999
        },
        {
          "intervention": "py_only_only",
          "cost": 278846.25,
          "casesAverted": 435.1814999999979
        },
        {
          "intervention": "py_only_with_lsm",
          "cost": 503846.25,
          "casesAverted": 14781.739499999996
        },
        {
          "intervention": "py_pbo_only",
          "cost": 313921.25,
          "casesAverted": 329.27849999999694
        },
        {
          "intervention": "py_pbo_with_lsm",
          "cost": 538921.25,
          "casesAverted": 14853.500999999997
        },
        {
          "intervention": "py_pyrrole_only",
          "cost": 348996.25,
          "casesAverted": 122.14349999999911
        },
        {
          "intervention": "py_pyrrole_with_lsm",
          "cost": 573996.25,
          "casesAverted": 14597.365499999998
        },
        {
          "intervention": "py_ppf_only",
          "cost": 348996.25,
          "casesAverted": 381.39749999999543
        },
        {
          "intervention": "py_ppf_with_lsm",
          "cost": 573996.25,
          "casesAverted": 14350.288499999995
        }
      ]
    },
    {
      "region": "dasd",
      "interventions": [
        {
          "intervention": "py_only_only",
          "cost": 464855.5555555555,
          "casesAverted": 1800.1499999999965
        },
        {
          "intervention": "py_pbo_only",
          "cost": 484680.2777777778,
          "casesAverted": 134.77999999999497
        },
        {
          "intervention": "py_pyrrole_only",
          "cost": 513391.9444444445,
          "casesAverted": -1080.5099999999925
        },
        {
          "intervention": "py_ppf_only",
          "cost": 533900.2777777778,
          "casesAverted": -92.4600000000055
        }
      ]
    },
    {
      "region": "dsad",
      "interventions": [
        {
          "intervention": "irs_only",
          "cost": 1215000,
          "casesAverted": 8609.081999999999
        },
        {
          "intervention": "lsm_only",
          "cost": 900000,
          "casesAverted": 39833.60999999999
        },
        {
          "intervention": "py_ppf_only",
          "cost": 455062.6666666666,
          "casesAverted": 1922.2800000000007
        },
        {
          "intervention": "py_ppf_with_lsm",
          "cost": 1355062.6666666665,
          "casesAverted": 9076.265999999996
        }
      ]
    }
  ]
}'
  jsonlite::fromJSON(json_txt, flatten = TRUE, simplifyVector = TRUE)
}

