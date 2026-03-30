# =============================================================================
# Loading distribution maps (present) from S3 or local
# =============================================================================

# load present distribution maps for all species in species_set
load_maps <- function(species_set, DATA_FOLDER) {

  # load distribution maps present climate
  log_step("n02", "Loading distribution maps present climate...")

  maps_folder <- file.path(DATA_FOLDER, "Maps", "Presence-absence")
  distr_stack <- NULL

  for (sp in species_set) {
    map_path <- file.path(maps_folder, paste0(sp, ".tif"))
    rast_obj <- load_raster(map_path)

    if (inherits(rast_obj, "SpatRaster")) {
      if (is.null(distr_stack)) {
        distr_stack <- rast_obj
      } else {
        distr_stack <- c(distr_stack, rast_obj)
      }
    } else {
      cat(paste0("  WARNING: Could not load map for species: ", sp, "\n"))
    }
  }
  
  # load distribution maps future climate
  log_step("n03", "Loading distribution maps future climate...")
  
  maps_folder <- file.path(DATA_FOLDER, "Maps", "Future")
  distr_stack_future <- NULL
  
  for (sp in species_set) {
    map_path <- file.path(maps_folder, paste0(sp, ".tif"))
    rast_obj <- load_raster(map_path)
    
    if (inherits(rast_obj, "SpatRaster")) {
      if (is.null(distr_stack_future)) {
        distr_stack_future <- rast_obj
      } else {
        distr_stack_future <- c(distr_stack_future, rast_obj)
      }
    } else {
      cat(paste0("  WARNING: Could not load map for species: ", sp, "\n"))
    }
  }
  
  # return of the function
  list(distr_stack = distr_stack, distr_stack_future = distr_stack_future)
  
}

