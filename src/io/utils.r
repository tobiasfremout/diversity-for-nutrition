normalize_fs_path <- function(path) {
  normalizePath(path.expand(path), winslash = "/", mustWork = FALSE)
}

split_s3_key <- function(key) {
  key <- gsub("\\\\", "/", key)
  key <- gsub("^/+", "", key)
  key <- gsub("/+$", "", key)
  if (!nzchar(key)) {
    return(character(0))
  }
  strsplit(key, "/", fixed = TRUE)[[1]]
}

local_path_from_key <- function(base_path, key) {
  parts <- split_s3_key(key)
  do.call(file.path, c(list(base_path), as.list(parts)))
}

join_s3_key <- function(...) {
  parts <- unlist(list(...), use.names = FALSE)
  parts <- as.character(parts)
  parts <- parts[nzchar(parts)]
  parts <- gsub("\\\\", "/", parts)
  parts <- gsub("^/+", "", parts)
  parts <- gsub("/+$", "", parts)
  paste(parts, collapse = "/")
}

relative_path_from_base <- function(path, base_dir) {
  path_norm <- normalize_fs_path(path)
  base_norm <- normalize_fs_path(base_dir)
  base_with_sep <- paste0(base_norm, "/")
  if (startsWith(path_norm, base_with_sep)) {
    return(sub("^/+", "", substring(path_norm, nchar(base_with_sep) + 1)))
  }
  basename(path_norm)
}

coords2country <- function(lon, lat) {
  shapefile_base <- file.path(DATA_FOLDER, "world_shp/WB_countries_Admin0_10m.shp")

  # Download main shapefile (.shp) which also downloads .shx and .dbf companions
  shp_file <- download_from_s3(shapefile_base)

  if (is.null(shp_file) || !file.exists(shp_file)) {
    stop("Failed to download countries shapefile from S3: ", shapefile_base)
  }

  # Expected paths for related shapefile components
  shx_file <- sub("\\.shp$", ".shx", shp_file)
  dbf_file <- sub("\\.shp$", ".dbf", shp_file)

  if (!file.exists(shx_file) || !file.exists(dbf_file)) {
    stop("Missing shapefile components (.shx or .dbf). Verify they exist in S3.")
  }

  col <- terra::vect(shp_file)
  # Create points in WGS84; terra::extract handles projection automatically
  pointsSP <- terra::vect(matrix(c(lon, lat), ncol = 2), type = "points", crs = "EPSG:4326")
  indices <- terra::extract(col, pointsSP)

  # Try multiple country code columns (different shapefiles use different names)
  country <- NULL
  for (col_name in c("ISO_A3", "ADM0_A3", "WB_A3", "iso_a3", "adm0_a3")) {
    if (col_name %in% names(indices) && !is.na(indices[[col_name]][1])) {
      country <- as.character(indices[[col_name]][1])
      break
    }
  }

  if (is.null(country) || is.na(country) || country == "") {
    stop("Could not determine country for (", lon, ", ", lat, "). ",
         "Available columns: ", paste(names(indices), collapse = ", "))
  }

  return(country)
}


load_raster <- function(file_path, farm = FALSE) {
  temp_file <- download_from_s3(file_path)

  if (is.null(temp_file) || !file.exists(temp_file)) {
    cat("ERROR: File does not exist or could not be downloaded:", file_path, "\n")
    return(0)
  }

  tryCatch({
    rast_obj <- terra::rast(temp_file)
    names(rast_obj) <- tools::file_path_sans_ext(basename(file_path))

    if (!isFALSE(farm)) {
      # Accept both 'Spatial' and 'SpatVector' objects
      if (inherits(farm, "SpatVector")) {
        farm_vect <- farm
      } else if (inherits(farm, "Spatial")) {
        farm_vect <- terra::vect(farm)
      } else {
        cat("ERROR: Farm object is not valid for extraction\n")
        return(0)
      }
      return(terra::extract(rast_obj, farm_vect))
    }

    return(rast_obj)
  }, error = function(e) {
    cat("ERROR: Failed to create SpatRaster:", file_path, "-", e$message, "\n")
    return(0)
  })
}

list_files_in_s3 <- function(bucket, prefix) {
  if (isTRUE(use_local)) {
    local_prefix_dir <- local_path_from_key(local_base_path, prefix)
    if (!dir.exists(local_prefix_dir)) {
      return(character(0))
    }

    local_files <- list.files(local_prefix_dir, recursive = TRUE, full.names = TRUE)
    if (length(local_files) == 0) {
      return(character(0))
    }

    base_norm <- normalizePath(local_base_path, winslash = "/", mustWork = FALSE)
    files_norm <- normalizePath(local_files, winslash = "/", mustWork = FALSE)
    file_paths <- vapply(files_norm, function(path) {
      base_with_sep <- paste0(base_norm, "/")
      if (startsWith(path, base_with_sep)) {
        substring(path, nchar(base_with_sep) + 1)
      } else {
        basename(path)
      }
    }, character(1))

    if (isTRUE(debug_mode)) cat("  [s3] listed", length(file_paths), "files locally for", prefix, "\n")
    return(file_paths)
  }

  tryCatch({
    objects <- s3$list_objects_v2(Bucket = bucket, Prefix = prefix)

    if (is.null(objects$Contents)) {
      if (isTRUE(debug_mode)) cat("  [s3] no objects found for prefix:", prefix, "\n")
      return(character(0))
    }

    file_paths <- sapply(objects$Contents, function(x) x$Key)
    if (isTRUE(debug_mode)) cat("  [s3] listed", length(file_paths), "files for", prefix, "\n")
    return(file_paths)

  }, error = function(e) {
    cat(paste0("ERROR in list_files_in_s3: ", e$message, " (prefix: ", prefix, ")\n"))
    return(character(0))
  })
}

init_cache <- function() {
  dir.create(CACHE_DIR, recursive = TRUE, showWarnings = FALSE)

  # Read remote version from S3
  remote_version <- tryCatch({
    raw <- s3$get_object(Bucket = BUCKET_NAME, Key = CACHE_VERSION_KEY)$Body
    trimws(rawToChar(raw))
  }, error = function(e) {
    NULL  # File doesn't exist, skip invalidation
  })

  # Read local version
  local_version_file <- file.path(CACHE_DIR, ".cache_version")
  local_version <- if (file.exists(local_version_file)) {
    trimws(readLines(local_version_file, n = 1, warn = FALSE))
  } else {
    NULL
  }

  # Compare and invalidate if different
  if (!is.null(remote_version) && !identical(remote_version, local_version)) {
    cat(paste0("Cache invalidated: remote version '", remote_version,
               "' vs local '", local_version, "'. Clearing cache...\n"))
    unlink(CACHE_DIR, recursive = TRUE)
    dir.create(CACHE_DIR, recursive = TRUE, showWarnings = FALSE)
    writeLines(remote_version, local_version_file)
  } else {
    cat(paste0("Cache valid (version: ", local_version %||% "no version", ")\n"))
  }
}

download_from_s3 <- function(object_key) {
  if (isTRUE(use_local)) {
    local_file_path <- local_path_from_key(local_base_path, object_key)
    if (!file.exists(local_file_path)) {
      cat(paste("ERROR: File not found locally:", object_key, "\n"))
      return(NULL)
    }

    if (tools::file_ext(object_key) == "shp") {
      for (ext in c("shx", "dbf", "prj", "cpg")) {
        related_local_path <- sub("\\.shp$", paste0(".", ext), local_file_path)
        if (!file.exists(related_local_path)) {
          cat(paste("WARNING: Missing shapefile component:", paste0(".", ext), "for", object_key, "\n"))
        }
      }
    }

    return(local_file_path)
  }

  # Build destination path in persistent cache directory
  local_file_path <- local_path_from_key(CACHE_DIR, object_key)

  # Cache hit
  if (file.exists(local_file_path)) {
    if (isTRUE(debug_mode)) cat("  [cache] hit:", object_key, "\n")
    return(local_file_path)
  }

  # Download from S3
  dir.create(dirname(local_file_path), recursive = TRUE, showWarnings = FALSE)
  if (isTRUE(debug_mode)) cat("  [s3] downloading:", object_key, "\n")

  tryCatch({
    s3_input <- get_object(object = object_key, bucket = BUCKET_NAME)
    if (length(s3_input) == 0) {
      cat(paste("ERROR: File not found in S3:", object_key, "\n"))
      return(NULL)
    }
    writeBin(s3_input, local_file_path)

    # Detect S3 XML error responses (NoSuchKey, AccessDenied, etc.)
    first_line <- tryCatch(readLines(local_file_path, n = 1, warn = FALSE), error = function(e) "")
    if (length(first_line) > 0 && grepl("^<\\?xml|^<Error", first_line)) {
      cat(paste("ERROR: S3 returned XML error for:", object_key, "\n"))
      unlink(local_file_path)
      return(NULL)
    }

    # If .shp, also download companion files
    if (tools::file_ext(object_key) == "shp") {
      for (ext in c("shx", "dbf", "prj", "cpg")) {
        related_key <- sub("\\.shp$", paste0(".", ext), object_key)
        related_local_path <- sub("\\.shp$", paste0(".", ext), local_file_path)
        if (file.exists(related_local_path)) next  # Already cached
        s3_related_input <- get_object(object = related_key, bucket = BUCKET_NAME)
        if (length(s3_related_input) > 0) {
          writeBin(s3_related_input, related_local_path)
        }
      }
    }

    return(local_file_path)
  }, error = function(e) {
    cat(paste("ERROR: Failed to download from S3:", object_key, "-", e$message, "\n"))
    return(NULL)
  })
}

upload_to_s3 <- function(file, base_dir, s3_base_path, bucket) {
  relative_path <- relative_path_from_base(file, base_dir)
  s3_path <- join_s3_key(s3_base_path, basename(normalize_fs_path(base_dir)), relative_path)

  if (isTRUE(use_local)) {
    local_output_path <- local_path_from_key(local_base_path, s3_path)
    dir.create(dirname(local_output_path), recursive = TRUE, showWarnings = FALSE)
    copied <- file.copy(file, local_output_path, overwrite = TRUE)
    if (!isTRUE(copied)) {
      stop("Failed to copy file locally: ", local_output_path)
    }
    return(invisible(local_output_path))
  }

  # Read the file
  file_content <- readBin(file, "raw", file.info(file)$size)

  # Upload the file to S3
  s3$put_object(
    Bucket = bucket,
    Key = s3_path,
    Body = file_content
  )
}
