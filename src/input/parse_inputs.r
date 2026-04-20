# =============================================================================
# R/parse_inputs.r
# Parsing and class conversion of input parameters from the web app
# All parameters arrive as strings and need to be converted to proper R classes
# =============================================================================

parse_nutrition_inputs <- function(lon,
                                   lat,
                                   edible_parts_ID,
                                   food_groups_ID,
                                   growth_forms_ID,
                                   species_type_ID,
                                   soil_con_ID,
                                   within_range,
                                   incl_tentative,
                                   SSP,
                                   language_output
                                   ) {
  
  # convert numeric parameters
  lon <- as.numeric(lon)
  lat <- as.numeric(lat)
  
  # normalize string parameters (remove whitespace)
  within_range <- trimws(as.character(within_range))
  incl_tentative <- trimws(as.character(incl_tentative))
  SSP <- trimws(as.character(SSP))
  language_output <- toupper(trimws(as.character(language_output)))

  # process ID lists (convert from comma-separated strings to vectors)
  if (edible_parts_ID == "NULL"){
    edible_parts_ID <- NULL
  } else {
    edible_parts_ID <- unlist(strsplit(trimws(as.character(edible_parts_ID)), split=","))
    edible_parts_ID <- trimws(edible_parts_ID)
  }
  
  if (food_groups_ID == "NULL"){
    food_groups_ID <- NULL
  } else {
    food_groups_ID <- unlist(strsplit(trimws(as.character(food_groups_ID)), split=","))
    food_groups_ID <- trimws(food_groups_ID)
  }
  
  if (growth_forms_ID == "NULL"){
    growth_forms_ID <- NULL
  } else {
    growth_forms_ID <- unlist(strsplit(trimws(as.character(growth_forms_ID)), split=","))
    growth_forms_ID <- trimws(growth_forms_ID)
  }
  
  if (species_type_ID == "NULL"){
    species_type_ID <- NULL
  } else {
    species_type_ID <- unlist(strsplit(trimws(as.character(species_type_ID)), split=","))
    species_type_ID <- trimws(species_type_ID)
  }
  
  if (soil_con_ID == "NULL"){
     soil_con_ID <- NULL
  } else {
     soil_con_ID <- unlist(strsplit(trimws(as.character(soil_con_ID)), split=","))
     soil_con_ID <- trimws(soil_con_ID)
  }
  
  # Return all parsed parameters as a named list
  list(
    lon = lon,
    lat = lat,
    edible_parts_ID = edible_parts_ID,
    food_groups_ID = food_groups_ID,
    growth_forms_ID = growth_forms_ID,
    species_type_ID = species_type_ID,
    soil_con_ID = soil_con_ID,
    within_range = within_range,
    incl_tentative = incl_tentative,
    SSP = SSP,
    language_output = language_output
  )
}