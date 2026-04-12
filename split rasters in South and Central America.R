# load packages
library(terra)
library(geodata)

# define extent
ext_sa <- ext(-82, -34, -56,  9)   # South America, up to Panama border

# get world shapefile and masks for Central and South America
world <- world(resolution = 1, path = tempdir())
sa_countries <- c("Colombia", "Venezuela", "Guyana", "Suriname", "French Guiana",
                  "Ecuador", "Peru", "Bolivia", "Brazil", "Chile", "Argentina",
                  "Uruguay", "Paraguay")
ca_countries <- c("Mexico", "Guatemala", "Belize", "Honduras", "El Salvador",
                  "Nicaragua", "Costa Rica", "Panama",
                  "Cuba", "Jamaica", "Haiti", "Dominican Republic", "Puerto Rico",
                  "Trinidad and Tobago", "Barbados", "Saint Lucia", "Grenada",
                  "Saint Vincent and the Grenadines", "Antigua and Barbuda",
                  "Dominica", "Saint Kitts and Nevis", "Bahamas")
sa_mask <- world[world$NAME_0 %in% sa_countries, ]
ca_mask <- world[world$NAME_0 %in% ca_countries, ]

# check which ca_countries were matched
cat("unmatched CA countries:\n")
print(ca_countries[!ca_countries %in% unique(world$NAME_0)])

# presence maps masked by hull
in_dir  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps/Presence-absence masked by hull"
out_sa  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps SA/Presence-absence masked by hull"
out_ca  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps CA/Presence-absence masked by hull"
files <- list.files(in_dir, pattern = "\\.tif$", full.names = TRUE)
for (f in files) {
  print(f)
  r <- rast(f)
  fname <- basename(f)
  crop(r, ext(-82, -34, -56, 13)) |> mask(sa_mask) |> writeRaster(file.path(out_sa, fname), overwrite = TRUE)
  crop(r, ext(-118, -59, 7, 27)) |> mask(ca_mask) |> writeRaster(file.path(out_ca, fname), overwrite = TRUE)
}

# presence maps not masked by hull
in_dir  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps/Presence-absence"
out_sa  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps SA/Presence-absence"
out_ca  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps CA/Presence-absence"
files <- list.files(in_dir, pattern = "\\.tif$", full.names = TRUE)
for (f in files) {
  print(f)
  r <- rast(f)
  fname <- basename(f)
  crop(r, ext(-82, -34, -56, 13)) |> mask(sa_mask) |> writeRaster(file.path(out_sa, fname), overwrite = TRUE)
  crop(r, ext(-118, -59, 7, 27)) |> mask(ca_mask) |> writeRaster(file.path(out_ca, fname), overwrite = TRUE)
}

# future masked by hull - SSP2
in_dir  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps/Future masked by hull/SSP2"
out_sa  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps SA/Future masked by hull/SSP2"
out_ca  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps CA/Future masked by hull/SSP2"
files <- list.files(in_dir, pattern = "\\.tif$", full.names = TRUE)
for (f in files) {
  print(f)
  r <- rast(f)
  fname <- basename(f)
  crop(r, ext(-82, -34, -56, 13)) |> mask(sa_mask) |> writeRaster(file.path(out_sa, fname), overwrite = TRUE)
  crop(r, ext(-118, -59, 7, 27)) |> mask(ca_mask) |> writeRaster(file.path(out_ca, fname), overwrite = TRUE)
}

# future masked by hull - SSP3
in_dir  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps/Future masked by hull/SSP3"
out_sa  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps SA/Future masked by hull/SSP3"
out_ca  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps CA/Future masked by hull/SSP3"
files <- list.files(in_dir, pattern = "\\.tif$", full.names = TRUE)
for (f in files) {
  print(f)
  r <- rast(f)
  fname <- basename(f)
  crop(r, ext(-82, -34, -56, 13)) |> mask(sa_mask) |> writeRaster(file.path(out_sa, fname), overwrite = TRUE)
  crop(r, ext(-118, -59, 7, 27)) |> mask(ca_mask) |> writeRaster(file.path(out_ca, fname), overwrite = TRUE)
}

# future not masked by hull - SSP2
in_dir  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps/Future/SSP2"
out_sa  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps SA/Future/SSP2"
out_ca  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps CA/Future/SSP2"
files <- list.files(in_dir, pattern = "\\.tif$", full.names = TRUE)
for (f in files) {
  print(f)
  r <- rast(f)
  fname <- basename(f)
  crop(r, ext(-82, -34, -56, 13)) |> mask(sa_mask) |> writeRaster(file.path(out_sa, fname), overwrite = TRUE)
  crop(r, ext(-118, -59, 7, 27)) |> mask(ca_mask) |> writeRaster(file.path(out_ca, fname), overwrite = TRUE)
}


# future not masked by hull - SSP3
in_dir  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps/Future/SSP3"
out_sa  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps SA/Future/SSP3"
out_ca  <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Maps CA/Future/SSP3"
files <- list.files(in_dir, pattern = "\\.tif$", full.names = TRUE)
for (f in files) {
  print(f)
  r <- rast(f)
  fname <- basename(f)
  crop(r, ext(-82, -34, -56, 13)) |> mask(sa_mask) |> writeRaster(file.path(out_sa, fname), overwrite = TRUE)
  crop(r, ext(-118, -59, 7, 27)) |> mask(ca_mask) |> writeRaster(file.path(out_ca, fname), overwrite = TRUE)
}









