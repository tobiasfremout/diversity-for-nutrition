# =============================================================================
# Determine biome based on coordinates
# =============================================================================
get_biome <- function(lon,
                      lat,
                      DATA_FOLDER
                      ) {
  
  # load biome shapefile
  log_step("n02 [get_biome]", "Getting biome...")
  shp_key <- file.path(DATA_FOLDER, "Shapefile biomes", "Ecoregions_LATAM.shp")
  local_file <- download_from_s3(shp_key)
  biome <- vect(local_file)
  
  # get biome at the coordinates
  e <- terra::extract(biome, cbind(lon, lat))
  biome_name <- e$BIOME_NAME
  
  # return of the function
  biome_name
  
}
  