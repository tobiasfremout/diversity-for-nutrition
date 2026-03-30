# =============================================================================
# R/load_data.r
# Loading data from S3 and filtering objectives/conditions/species
# =============================================================================

# load data
load_data <- function(DATA_FOLDER) {
  
  log_step("n01 [load_data]", "Loading nutrition data...")
  
  # load nutrition data
  nutr_dat <- safe_read_csv(file.path(DATA_FOLDER, "Tables", "species_nutrition_data.csv"))

  # load soil extremes data
  # soil_dat <- safe_read_csv(file.path(DATA_FOLDER, "soil_extremes.csv"))
  
  # get the species for which models were made
  j <- which(nutr_dat$incl_SDM == 1)
  species_set <- nutr_dat$species[j]
  
  # return of the function
  list(
    nutr_dat = nutr_dat,
    # soil_dat = soil_dat,
    species_set = species_set
  )
}
