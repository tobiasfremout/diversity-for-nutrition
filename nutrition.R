# Orchestrator script for Diversity for Nutrition tool

# set R_HOME
R_HOME <- "C:/Users/tobia/Documents/GitHub/diversity-for-nutrition"

# source config.R
source(file.path(R_HOME, "config.R"))

# reset R_HOME
R_HOME <- "C:/Users/tobia/Documents/GitHub/diversity-for-nutrition"

# source scripts
source(file.path(R_HOME, "src", "io", "helpers.r"))
source(file.path(R_HOME, "src", "io", "utils.r"))
source(file.path(R_HOME, "src", "input", "parse_inputs.r"))
source(file.path(R_HOME, "src", "data", "load_data.r"))
source(file.path(R_HOME, "src", "data", "load_maps.r"))
source(file.path(R_HOME, "src", "analysis", "species_analysis.r"))
source(file.path(R_HOME, "src", "output", "visualization.r"))
source(file.path(R_HOME, "src", "output", "report_html.r"))

# main function to call the other functions
process_nutrition <- function(lon,
                              lat) {
    
    ##############################################################################
    # 1. Parse inputs
    ##############################################################################
    inputs <- parse_nutrition_inputs(
      lon = lon,
      lat = lat,
      edible_parts_ID = edible_parts_ID,
      food_groups_ID = food_groups_ID,
      growth_forms_ID = growth_forms_ID,
      species_type = species_type,
      within_range = within_range,
      incl_tentative = incl_tentative,
      SSP = SSP,
      language_output
    )
    
    ##############################################################################
    # 2. Load data
    ##############################################################################
    data <- load_data(
      DATA_FOLDER = DATA_FOLDER
    )
    
    ##############################################################################
    # 3. Load maps
    ##############################################################################
    data <- load_maps(
      DATA_FOLDER = DATA_FOLDER
    )
    
    ##############################################################################
    # 3. Species analysis
    ##############################################################################
    species_res <- analyze_species(
      coords = coords,
      data = data,
      inputs = inputs,
      tool_mode = tool_mode,
      country = country,
      region_spec = region_spec,
      only_native = only_native,
      multifun = multifun,
      language_output = language_output,
      debug_mode = debug_mode
    )
    
    ##############################################################################
    # 3. Visualization
    ##############################################################################
    vis <- visualize(

    )

    
    ##############################################################################
    # 4. Generate HTML report
    ##############################################################################
    generate_report(
      outputResul = outputResul,
      FileLog = FileLog,
      startTime = startTime
    )
    
}
