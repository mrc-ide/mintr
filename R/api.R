api <- function() {
  pr <- pkgapi::pkgapi$new()
  pr$handle(endpoint_table_impact_config())
  pr
}


endpoint_table_impact_config <- function() {
  pkgapi::pkgapi_endpoint$new(
    "GET", "/table/impact/config", target_table_impact_config,
    returning = pkgapi::pkgapi_returning_json("TableDefinition.schema",
                                              schema_root()),
    validate = TRUE)
}


target_table_impact_config <- function() {
  read_json(mintr_path("json/table_impact_config.json"))
}
