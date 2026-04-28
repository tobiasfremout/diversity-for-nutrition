# load packages
library(rnaturalearth)
library(sf)
library(terra)

# load raster with right extent
setwd(dir = "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/D4N_data/Maps/Presence-absence")
r <- rast("Abarema killipii.tif")

# latin america country codes (iso_a2)
latam_iso <- c(
  "MX", "GT", "BZ", "HN", "SV", "NI", "CR", "PA",  # central america + mexico
  "CU", "JM", "HT", "DO", "PR", "TT", "BB", "LC",   # caribbean
  "VC", "GD", "AG", "DM", "KN",
  "CO", "VE", "GY", "SR", "EC", "PE", "BR",          # south america
  "BO", "PY", "CL", "AR", "UY"
)

# get world countries as sf
world <- ne_countries(scale = "medium", returnclass = "sf")

# subset to latin america
latam <- world[world$iso_a2 %in% latam_iso, ]

# crop to raster extent
latam_crop <- st_crop(latam, r)

# save as geojson
setwd(dir = "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/D4N_data/world_shp")
st_write(latam_crop, "latam_countries_simplified.geojson", driver = "GeoJSON", delete_dsn = TRUE)
