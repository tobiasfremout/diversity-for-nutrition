# =============================================================================
# Generate report data as JSON for a frontend (WordPress) to render.
# Replaces the previous report_html.r (R2HTML-based) approach.
# Same pattern as conservation-lambda-r/src/output/report_data.r.
# =============================================================================

generate_report_data <- function(inputs,
                                 country,
                                 region,
                                 biome_name,
                                 species_filt,
                                 trans_df,
                                 output_folder) {

  log_step("n11 [report_data]", "Building report data JSON...")

  # Clean species table — add row index for DataTables
  species_df <- species_filt$nutr_table
  rownames(species_df) <- NULL
  if (nrow(species_df) > 0) {
    species_df$id <- seq_len(nrow(species_df))
  }

  # Translation labels for the selected language (may be NULL if trans_df empty)
  labels <- if (!is.null(trans_df) && nrow(trans_df) > 0) as.list(trans_df) else list()

  # Assemble the payload: echoes the inputs, adds derived context, ships the results.
  report_data <- list(
    coords = list(lon = inputs$lon, lat = inputs$lat),
    country = country,
    region = region,
    biome = biome_name,
    filters = list(
      edible_parts_ID = inputs$edible_parts_ID,
      food_groups_ID = inputs$food_groups_ID,
      growth_forms_ID = inputs$growth_forms_ID,
      species_type_ID = inputs$species_type_ID,
      soil_con_ID = inputs$soil_con_ID,
      within_range = inputs$within_range,
      incl_tentative = inputs$incl_tentative,
      SSP = inputs$SSP,
      language_output = inputs$language_output
    ),
    n_species = nrow(species_df),
    species = if (nrow(species_df) > 0) species_df else NULL,
    labels = labels
  )

  # Canonical JSON (consumed by WP PHP / any REST client)
  json_file <- file.path(output_folder, "data.json")
  writeLines(
    jsonlite::toJSON(report_data, auto_unbox = TRUE, pretty = TRUE, null = "null", na = "null"),
    json_file
  )

  # data.js — same payload exposed on `window.d4nReport` for direct <script src> loading.
  # Useful if the report wrapper HTML wants the data without a fetch().
  js_file <- file.path(output_folder, "data.js")
  writeLines(
    paste0(
      "window.d4nReport = ",
      jsonlite::toJSON(report_data, auto_unbox = TRUE, null = "null", na = "null"),
      ";"
    ),
    js_file
  )

  invisible(report_data)
}
