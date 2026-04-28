# load packages
library(readxl)

# set user of the script
user <- "Tobias"
# user <- "Chrystian"

# set base directory
if(user == "Tobias") {
  basedir <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/Data/Tables Chrystian"
}
if(user == "Chrystian") {
  basedir <- ""
}

# load data
setwd(dir = basedir)
dat <- read_excel("species_nutrition_data_202604013.xlsx", sheet = "tool_format")

# load keywords - food groups table
setwd(dir = basedir)
keywords <- read.csv("keywords_food_group.csv")

# make an empty list to store the results
dat_added <- list()

# loop through the rows
for (r in (1:nrow(dat))) {
  
  # get use
  use <- dat$use[r]
  
  # only continue of use is not NA
  if(!is.na(use)) {
    
    # check if any of the keywords are found in the use description
    for (k in 1:nrow(keywords)) {
      
      keyword <- keywords$keyword[k]
      g <- grepl(pattern = keyword,  use)
      
      # if yes, add the row as a new row to dat_new
      # but only if that species x food group combination is not in the database yet
      if(g == TRUE) {
        
        # check food groups for the species
        j <- which(dat$species == dat$species[r])
        food_groups <- dat$food_group[j]
        
        if(!(keywords$food_group[k] %in% food_groups)) {
          
          dat_new <- dat[r,]
          dat_new$food_group<- keywords$food_group[k]
          
          # leave empty part, edible_portion, plant_part, plant_part_tentative,
          # plant_part_ref, plant_part_assumption
          dat_new$part <- NA
          dat_new$edible_portion <- NA
          dat_new$plant_part <- "?"
          dat_new$plant_part_tentative <- "?"
          dat_new$plant_part_ref <- "?"
          dat_new$plant_part_assumption <- "?"
          print(paste0("row added: ", 
                       dat_new$food_group, " - ",
                       dat_new$use))
          
          # add to list
          dat_added[[length(dat_added) + 1]] <- dat_new
          
        }
      }
    }
  }
}

# rbind the list
dat_added <- do.call("rbind", dat_added)

# remove duplicates
i <- which(duplicated(paste0(dat_added$species, dat_added$food_groups)))
dat_added <- dat_added[-i,]



