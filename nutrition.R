# Orchestrator script for Diversity for Nutrition tool

# fixed inputs Tobias
R_HOME <- "C:/Users/tobia/Documents/GitHub/diversity-for-nutrition"
DATA_FOLDER <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/Data"

# source scripts
source(file.path(R_HOME, "src", "input", "parse_inputs.r"))
source(file.path(R_HOME, "src", "data", "load_data.r"))
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
    # 2. Load nutrition data
    ##############################################################################
    data <- load_nutrition_data(
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
