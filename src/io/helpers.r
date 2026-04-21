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

# Classify a country (ISO3 code) as part of South America ("SA") or Central
# America + Caribbean ("CA"). Used to decide which split of the species
# distribution maps to load when SPLIT_MAPS_BY_REGION=TRUE.
region_from_country <- function(iso3) {
  sa_countries <- c(
    "ARG", "BOL", "BRA", "CHL", "COL", "ECU",
    "GUF", "GUY", "PER", "PRY", "SUR", "URY", "VEN"
  )
  ca_countries <- c(
    "BLZ", "CRI", "GTM", "HND", "MEX", "NIC", "PAN", "SLV",
    "ABW", "ATG", "BHS", "BRB", "CUB", "CYM", "DMA", "DOM",
    "GRD", "HTI", "JAM", "KNA", "LCA", "MSR", "PRI", "TCA",
    "TTO", "VCT", "VGB", "VIR"
  )

  if (iso3 %in% sa_countries) return("SA")
  if (iso3 %in% ca_countries) return("CA")
  # Outside LatAm (e.g. USA via the Everglades ecoregion that the source
  # shapefile includes). Return NA so load_maps falls back to the combined
  # Maps/ folder instead of crashing; callers that need SA/CA will check.
  warning("Country '", iso3, "' is not mapped to a LatAm region (SA or CA). ",
          "Falling back to the combined Maps/ folder.")
  return(NA_character_)
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
