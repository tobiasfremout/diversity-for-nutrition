# Shared runtime configuration for Lambda and local execution.

R_HOME <- if (isTRUE(as.logical(Sys.getenv("USE_LOCAL_FILES", unset = "FALSE")))) {
  normalizePath(getwd(), winslash = "/", mustWork = FALSE)
} else {
  "/var/task"
}

BUCKET_NAME <- "diversity-for-nutrition"
DATA_FOLDER <- Sys.getenv("DATA_FOLDER", unset = "diversity-for-nutrition-data/Data")
OUTPUT_FOLDER <- "diversity"
TMP_FOLDER <- tempdir()
CACHE_DIR <- "/tmp/diversity-for-nutrition-cache"
CACHE_VERSION_KEY <- file.path(DATA_FOLDER, "cache_version.txt")

debug_mode <- as.logical(Sys.getenv("debug_mode", unset = "FALSE"))
if (is.na(debug_mode)) {
  debug_mode <- FALSE
}

use_local <- as.logical(Sys.getenv("USE_LOCAL_FILES", unset = "FALSE"))
if (is.na(use_local)) {
  use_local <- FALSE
}

local_base_path <- Sys.getenv("LOCAL_DATA_PATH", unset = "local_data")
if (!nzchar(local_base_path)) {
  local_base_path <- "local_data"
}
local_base_path <- normalizePath(path.expand(local_base_path), winslash = "/", mustWork = FALSE)

s3 <- NULL
if (!use_local) {
  s3 <- paws::s3()
}