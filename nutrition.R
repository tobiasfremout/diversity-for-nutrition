# Orchestrator script for Diversity for Nutrition tool

# set R_HOME
R_HOME <- "C:/Users/tobia/Documents/GitHub/diversity-for-nutrition"

# source config.R
source(file.path(R_HOME, "config.R"))

# reset R_HOME
R_HOME <- "C:/Users/tobia/Documents/GitHub/diversity-for-nutrition"

# source scripts
source(file.path(R_HOME, "src", "libs.r"))
source(file.path(R_HOME, "src", "io", "helpers.r"))
source(file.path(R_HOME, "src", "io", "utils.r"))
source(file.path(R_HOME, "src", "input", "parse_inputs.r"))
source(file.path(R_HOME, "src", "input", "get_biome.r"))
source(file.path(R_HOME, "src", "data", "load_data.r"))
source(file.path(R_HOME, "src", "data", "load_maps.r"))
source(file.path(R_HOME, "src", "analysis", "species_analysis.r"))
# source(file.path(R_HOME, "src", "output", "visualization.r"))
source(file.path(R_HOME, "src", "output", "report_html.r"))

# main function to call the other functions
process_nutrition <- function(lon = NULL,
                              lat = NULL,
                              edible_parts_ID = NULL,
                              food_groups_ID = NULL,
                              growth_forms_ID = NULL,
                              species_type_ID = NULL,
                              soil_con_ID = NULL,
                              within_range = NULL,
                              incl_tentative = NULL,
                              SSP = NULL,
                              language_output = NULL) {
    
    ##############################################################################
    # 1. Parse inputs
    ##############################################################################
    inputs <- parse_nutrition_inputs(
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
    # print(inputs)
    
    ##############################################################################
    # 1. Load data
    ##############################################################################
    data <- load_data(
      DATA_FOLDER = DATA_FOLDER,
      language_output = inputs$language_output
    )
    # print(data)
    
    ##############################################################################
    # 2. Get biome
    ##############################################################################
    biome <- get_biome(
      lon = lon,
      lat = lat,
      DATA_FOLDER = DATA_FOLDER
    )
    # print(biome)
    
    ##############################################################################
    # 3. Load maps
    ##############################################################################
    maps <- load_maps(
      species_set = data$species_set,
      DATA_FOLDER = DATA_FOLDER,
      BUCKET_NAME = BUCKET_NAME,
      within_range = inputs$within_range,
      SSP = inputs$SSP,
      biome = biome$biome_name
    )
    # print(maps)
    
    ##############################################################################
    # 4. Extract species that can grow at selected site
    ##############################################################################
    species_extr <- extract_suitable_species(
      lon = lon,
      lat = lat,
      maps_present = maps$distr_stack,
      maps_future = maps$distr_stack_future
    )
    # print(species_extr)
    
    ##############################################################################
    # 5. Filter species
    ##############################################################################
    species_filt <- filter_species(
      nutr_dat = data$nutr_dat,
      soil_dat = data$soil_dat,
      edible_parts = data$edible_parts,
      food_groups = data$food_groups,
      growth_forms = data$growth_forms,
      species_types = data$species_types,
      suitable_species = species_extr$suitable_species,
      n_models = species_extr$n_models,
      edible_parts_ID = inputs$edible_parts_ID,
      food_groups_ID = inputs$food_groups_ID,
      growth_forms_ID = inputs$growth_forms_ID,
      species_type_ID = inputs$species_type_ID,
      soil_con_ID = inputs$soil_con_ID,
      biome = biome$biome_name,
      incl_tentative = inputs$incl_tentative,
      language_output = inputs$language_output
    )
    print(species_filt)
    
    ##############################################################################
    # 6. Visualization
    ##############################################################################
    # vis <- visualize(species_res = species_res)
    
    ##############################################################################
    # 7. Generate HTML report
    ##############################################################################
    generate_html_report(
      nutr_table = species_filt$nutr_table,
      output_result = REPORT_FOLDER,
      language_output = inputs$language_output,
      trans_df = data$trans_df
    )
    
}
