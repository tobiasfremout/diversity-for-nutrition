# load packages
library(jsonlite)

# source functions.R
source("functions.r")

# put parameters in local environment for easier debugging
lat = lat
edible_parts_ID = edible_parts_ID
food_groups_ID = food_groups_ID
growth_forms_ID = growth_forms_ID
species_type = species_type
within_range = within_range
incl_tentative = incl_tentative
SSP = SSP
language_output = language_output

# call mainNutrition functions
mainNutrition(
  lon = lon,
  lat = lat,
  edible_parts_ID = edible_parts_ID,
  food_groups_ID = food_groups_ID,
  growth_forms_ID = growth_forms_ID,
  species_type = species_type,
  within_range = within_range,
  incl_tentative = incl_tentative,
  SSP = SSP,
  language_output = language_output
)
  