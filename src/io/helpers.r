# =============================================================================
# Helper functions used across multiple modules
# =============================================================================

# Logging helper for execution tracking (used by orchestrator and modules)
log_step <- function(step, msg) {
  cat(paste0(step, ".(", format(Sys.time(), "%H:%M:%S"), ") ", msg, "\n"))
}

# Function to convert Unicode characters to HTML numeric entities
# This ensures proper rendering in HTML reports, similar to Vietnamese approach
unicode_to_html <- function(text) {
  if (is.na(text) || is.null(text) || text == "") return(text)

  # Ensure text is UTF-8 encoded
  text <- enc2utf8(text)

  # Split text into characters
  chars <- strsplit(text, "")[[1]]

  # Convert each character
  result <- sapply(chars, function(char) {
    # Try to get the UTF-8 code point
    code <- tryCatch({
      utf8ToInt(char)
    }, error = function(e) {
      # If there's an error, return the character as-is
      return(char)
    })

    # If code is a character (error case), return it as-is
    if (!is.numeric(code)) return(char)
    # Convert Lao characters (U+0E80 to U+0EFF) and other non-ASCII to HTML entities
    if (code >= 0x0E80 && code <= 0x0EFF) {
      paste0("&#", code, ";")
    } else if (code > 127) {  # Other non-ASCII characters
      paste0("&#", code, ";")
    } else {
      char  # Keep ASCII characters as-is
    }
  })

  paste(result, collapse = "")
}

# Reverse geocode coordinates using Nominatim (OpenStreetMap) API
# Returns a list with: country, state, city (best available locality)
# language_output: "EN", "ES", "FR", "VI", "LO" — controls the language of place names
reverse_geocode <- function(lon, lat, language_output = "EN") {
  lang_map <- c(EN = "en", ES = "es", FR = "fr", VI = "vi", LO = "lo")
  accept_lang <- if (language_output %in% names(lang_map)) lang_map[[language_output]] else "en"

  result <- list(country = NULL, state = NULL, city = NULL)
  tryCatch({
    url <- paste0(
      "https://nominatim.openstreetmap.org/reverse",
      "?format=json&lat=", lat, "&lon=", lon, "&zoom=10&addressdetails=1",
      "&accept-language=", accept_lang
    )
    response <- httr::GET(url, httr::user_agent("D4R-Tool/1.0 (restoration-tool)"))
    if (httr::status_code(response) == 200) {
      data <- httr::content(response, as = "parsed", type = "application/json")
      addr <- data$address
      result$country <- addr$country
      result$state   <- if (!is.null(addr$state))    addr$state    else
                        if (!is.null(addr$province)) addr$province else
                        if (!is.null(addr$region))   addr$region   else NULL
      result$city    <- if (!is.null(addr$city))         addr$city         else
                        if (!is.null(addr$town))         addr$town         else
                        if (!is.null(addr$village))      addr$village      else
                        if (!is.null(addr$municipality)) addr$municipality else NULL
    }
  }, error = function(e) {
    cat(paste0("  [reverse_geocode] Warning: could not fetch location info: ", e$message, "\n"))
  })
  return(result)
}

# Helper function to safely read CSVs from S3
safe_read_csv <- function(path, ...) {
  temp_file <- download_from_s3(path)
  if (is.null(temp_file) || !file.exists(temp_file)) {
    cat(paste0("ERROR: Failed to download or find file: ", path, "\n"))
    stop(paste0("CRITICAL ERROR: Missing required file: ", path))
  }
  tryCatch({
    return(read.csv(temp_file, ...))
  }, error = function(e) {
    cat(paste0("ERROR: Failed to read CSV: ", path, " - ", e$message, "\n"))
    stop(paste0("CRITICAL ERROR: Invalid CSV file: ", path))
  })
}
