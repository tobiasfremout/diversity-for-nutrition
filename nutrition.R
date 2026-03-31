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
source(file.path(R_HOME, "src", "data", "load_data.r"))
source(file.path(R_HOME, "src", "data", "load_maps.r"))
source(file.path(R_HOME, "src", "analysis", "species_analysis.r"))
# source(file.path(R_HOME, "src", "output", "visualization.r"))
source(file.path(R_HOME, "src", "output", "report_html.r"))

# main function to call the other functions
process_nutrition <- function(lon = lon,
                              lat = lat,
                              edible_parts_ID = edible_parts_ID,
                              food_groups_ID = food_groups_ID,
                              growth_forms_ID = growth_forms_ID,
                              species_type_ID = species_type_ID,
                              within_range = within_range,
                              incl_tentative = incl_tentative,
                              SSP = SSP,
                              language_output = language_output) {
    
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
      within_range = within_range,
      incl_tentative = incl_tentative,
      SSP = SSP,
      language_output = language_output
    )
    # print(inputs)
    
    ##############################################################################
    # 2. Load data
    ##############################################################################
    data <- load_data(
      DATA_FOLDER = DATA_FOLDER
    )
    # print(data)
    
    ##############################################################################
    # 3. Load maps
    ##############################################################################
    maps <- load_maps(
      species_set = species_set,
      DATA_FOLDER = DATA_FOLDER,
      within_range = within_range,
      SSP = SSP
    )
    # print(maps)
    
    ##############################################################################
    # 4. Extract species that can grow at selected site
    ##############################################################################
    species_extr <- extract_suitable_species(
      lon = lon,
      lat = lat,
      maps = maps
    )
    # print(species_extr)
    
    ##############################################################################
    # 5. Filter species
    ##############################################################################
    species_filt <- filter_species(
      nutr_dat = data$nutr_dat,
      edible_parts = data$edible_parts,
      food_groups = data$food_groups,
      growth_forms = data$growth_forms,
      species_types = data$species_types,
      suitable_species = species_extr$suitable_species,
      n_models = species_extr$n_models,
      edible_parts_ID = inputs$edible_parts_ID,
      food_groups_ID = food_groups_ID,
      growth_forms_ID = growth_forms_ID,
      species_type_ID = species_type_ID,
      incl_tentative = incl_tentative,
      language_output = language_output
    )
    
    ##############################################################################
    # 6. Visualization
    ##############################################################################
    # vis <- visualize(species_res = species_res)
    
    ##############################################################################
    # 4. Generate HTML report
    ##############################################################################
    generate_html_report(
      nutr_table = species_filt$nutr_table,
      output_result = REPORT_FOLDER,
      language_output = language_output
    )
    
}
