# =============================================================================
# Loading distribution maps (present) from S3 or local
# =============================================================================

# load present distribution maps for all species in species_set
load_maps <- function(species_set, 
                      DATA_FOLDER,
                      BUCKET_NAME,
                      within_range,
                      SSP,
                      biome) {

  # load distribution maps present climate
  log_step("n03 [load_maps]", "Loading distribution maps present climate...")
  
  if(within_range == "yes") {
    maps_folder <- file.path(DATA_FOLDER, "Maps", "Presence-absence masked by hull")
  }
  if(within_range == "no") {
    maps_folder <- file.path(DATA_FOLDER, "Maps", "Presence-absence")
  }
  files <- list_files_in_s3(bucket = BUCKET_NAME, prefix = maps_folder)
  files <- files[grepl("\\.tif$", files)]
  distr_stack <- terra::rast(lapply(files, load_raster))
  
  # change the names to the species names only
  names(distr_stack) <- tools::file_path_sans_ext(basename(sources(distr_stack)))
  
  # load distribution maps future climate
  log_step("n04 [load_maps]", "Loading distribution maps future climate...")
  
  if(within_range == "yes") {
    maps_folder <- file.path(DATA_FOLDER, "Maps", "Future masked by hull", SSP)
  }
  if(within_range == "no") {
    maps_folder <- file.path(DATA_FOLDER, "Maps", "Future", SSP)
  }
  files <- list_files_in_s3(bucket = BUCKET_NAME, prefix = maps_folder)
  files <- files[grepl("\\.tif$", files)]
  distr_stack_future <- terra::rast(lapply(files, load_raster))
  
  # change the names to the species names only
  names(distr_stack_future) <- tools::file_path_sans_ext(basename(sources(distr_stack_future)))

  # return of the function
  list(distr_stack = distr_stack, distr_stack_future = distr_stack_future)
  
}

