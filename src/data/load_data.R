# =============================================================================
# R/load_data.r
# Loading data from S3 and filtering objectives/conditions/species
# =============================================================================

# load data
load_data <- function(DATA_FOLDER) {
  
  cat(paste0("  [load_data] Loading nutrition data...\n"))
  
  # load nutrition data
  nutr_dat <- safe_read_csv(file.path(DATA_FOLDER, "Tables", "species_nutrition_data.csv"))

  # soil extremes data
  soil_dat <- safe_read_csv(file.path(DATA_FOLDER, "soil_extremes.csv"))
  
  list(
    nutr_dat = nutr_dat,
    soil_dat = soil_dat
  )
}
