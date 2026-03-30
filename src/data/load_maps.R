# =============================================================================
# Loading distribution maps (present/future) from S3
# =============================================================================

# load present and future distribution maps for all species
load_maps <- function(DATA_FOLDER) {
  
  cat(paste0("n02.(",format(Sys.time(), "%H:%M:%S"), ") Loading distribution maps...\n"))
  
  list(distr_stack = distr_stack, future_distr_stack = future_distr_stack)
}

