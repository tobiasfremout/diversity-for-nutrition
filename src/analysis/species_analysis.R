# =============================================================================
# Extract species that can grow at the selected coordinates
# =============================================================================
extract_suitable_species <- function(lon, lat, maps) {
  
  log_step("n05 [species_analysis]", "Extracting suitable species...")
  
  # make a dataframe with the clicked coordinates
  coords <- data.frame(lon = lon, lat = lat)
  
  # extract suitable species present climate
  e <- terra::extract(maps$distr_stack, coords)
  e <- e[,2:ncol(e)]
  names(e) <- names(distr_stack)
  j <- which(e[1,] == 1)
  suitable_species <- names(e)[j]
  
  # get number of models that predict future presence
  e <- terra::extract(maps$distr_stack_future, coords)
  e <- e[,2:ncol(e)]
  names(e) <- names(distr_stack)
  n_models <- e[1,j]
  
  # return of the function
  list(
    suitable_species = suitable_species,
    n_models = n_models
  )
  
}

# =============================================================================
# Filter species according to user inputs
# =============================================================================
filter_species <- function(nutr_dat,
                           soil_dat,
                           edible_parts,
                           food_groups,
                           growth_forms,
                           species_types,
                           suitable_species,
                           n_models,
                           edible_parts_ID,
                           food_groups_ID,
                           growth_forms_ID,
                           species_type_ID,
                           soil_con_ID,
                           biome,
                           incl_tentative,
                           language_output) {
  
  log_step("n06 [species_analysis]", "Filtering species: only suitable species...")
  
  # select only the suitable species
  j <- which(nutr_dat$species %in% suitable_species)
  nutr_dat <- nutr_dat[j,]
  
  log_step("n07 [species_analysis]", "Filtering species: edible parts...")
  
  # select only the species with edible parts selected by the user
  if(edible_parts_ID[1] != 1) {
    m <- match(edible_parts_ID, edible_parts$ID)
    edible_parts_sel <- edible_parts$plant_part[m]
    j <- which(nutr_dat$plant_part %in% edible_parts_sel)
    nutr_dat <- nutr_dat[j,]
  }
  
  log_step("n08 [species_analysis]", "Filtering species: food groups...")
  
  # select only the species with food groups selected by the user
  if(food_groups_ID[1] != 1) {
    m <- match(food_groups_ID, food_groups$ID)
    food_groups_sel <- food_groups$food_group[m]
    j <- which(nutr_dat$food_group %in% food_groups_sel)
    nutr_dat <- nutr_dat[j,]
  }
  
  log_step("n09 [species_analysis]", "Filtering species: growth forms...")
  
  # select only the species with growth forms selected by the user
  if(growth_forms_ID[1] != 1) {
    m <- match(growth_forms_ID, growth_forms$ID)
    growth_forms_sel <- growth_forms$growth_form[m]
    j <- which(nutr_dat$growth_form %in% growth_forms_sel)
    nutr_dat <- nutr_dat[j,]
  }

  log_step("n09 [species_analysis]", "Filtering species: species types (wild/cultivated)...")
  
  # select only the species types selected by the user
  if(species_type_ID[1] != 1) {
    m <- match(species_type_ID, species_types$ID)
    species_type_sel <- species_types$species_type[m]
    j <- which(nutr_dat$species_type %in% species_type_sel)
    nutr_dat <- nutr_dat[j,]
  }
  
  log_step("n10 [species_analysis]", "Filtering species: soil conditions...")
  
  # select only the species with soil conditions (extremes) selected by the user
  if(soil_con_ID[1] != 1) {
    
    # get the rows corresponding to the selected soil extremes
    j <- which(soil_dat$category_ID %in% soil_con_ID)
    soil_dat_subset <- soil_dat[j,]

    # select only the species corresponding to these soil extremes
    j <- which(nutr_dat$species %in% unique(soil_dat_subset$species))
    nutr_dat <- nutr_dat[j,]
    
  }
  
  # select only relevant columns for report
  nutr_table <- nutr_dat[, c("species", "family", "growth_form", "wild_or_cultivated", "plant_part", "food_group", "use")]
  
  # return of the function
  list(
    nutr_table = nutr_table
  )
  
}





