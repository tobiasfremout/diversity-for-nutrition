# ============================================================
# prepare parquet table instead of maps.R
#
# Pre-extracts all 6,591 species rasters into one compressed
# Parquet file for fast downstream queries — replacing the
# need to load individual .tif files at analysis time.
#
# Run once whenever maps are updated. Requires ~2–4 GB RAM.
#
# Output columns:
#   species      — species name (from filename)
#   lon, lat     — pixel centre coordinates
#   present_now  — 0/1 from Presence-absence (unmasked)
#   present_ssp2 — 0/1 from Future/SSP2 (unmasked)
#   present_ssp3 — 0/1 from Future/SSP3 (unmasked)
#   within_hull  — TRUE if pixel is within the convex hull
#                  (derived from Presence-absence masked by hull)
#
# Only pixels where (present in any scenario) OR (within hull)
# are stored. All-absent, out-of-hull pixels are dropped.
# ============================================================

# load packages
library(terra)
library(data.table)
library(arrow)

# ---- Helper ------------------------------------------------
format_time <- function(secs) {
  secs <- round(secs)
  if (secs < 60)   return(sprintf("%ds", secs))
  if (secs < 3600) return(sprintf("%dm%02ds", secs %/% 60, secs %% 60))
  sprintf("%dh%02dm", secs %/% 3600, (secs %% 3600) %/% 60)
}

# ---- Paths --------------------------------------------------
base_maps <- "C:/Users/tobia/Dropbox/Diversity for Nutrition/diversity-for-nutrition-data/D4N_data/Maps"

dir_now  <- file.path(base_maps, "Presence-absence")
dir_hull <- file.path(base_maps, "Presence-absence masked by hull")
dir_ssp2 <- file.path(base_maps, "Future/SSP2")
dir_ssp3 <- file.path(base_maps, "Future/SSP3")

out_parquet <- file.path(
  dirname(base_maps),
  "species_presence.parquet"
)

# ---- Species list (dir_now is the reference) -----------
species_files <- list.files(dir_now, pattern = "\\.tif$", full.names = FALSE)
n_species     <- length(species_files)
cat(sprintf("Found %d species. Output: %s\n\n", n_species, out_parquet))

t_start <- proc.time()

# ---- Process each species ----------------------------------
results <- vector("list", n_species)
skipped <- character(0)

for (i in seq_along(species_files)) {
  fname   <- species_files[i]
  sp_name <- tools::file_path_sans_ext(fname)

  paths <- c(
    now  = file.path(dir_now,  fname),
    hull = file.path(dir_hull, fname),
    ssp2 = file.path(dir_ssp2, fname),
    ssp3 = file.path(dir_ssp3, fname)
  )

  missing <- paths[!file.exists(paths)]
  if (length(missing) > 0) {
    skipped <- c(skipped, sp_name)
    if (length(missing) < 4)
      warning(sprintf("Skipping '%s' — missing: %s",
                      sp_name, paste(names(missing), collapse = ", ")))
    next
  }

  stk <- tryCatch(
    c(rast(paths["now"]), rast(paths["hull"]),
      rast(paths["ssp2"]), rast(paths["ssp3"])),
    error = function(e) {
      warning(sprintf("Cannot stack '%s': %s", sp_name, conditionMessage(e)))
      NULL
    }
  )
  if (is.null(stk)) { skipped <- c(skipped, sp_name); next }

  names(stk) <- c("present_now", "hull_val", "present_ssp2", "present_ssp3")

  df <- as.data.frame(stk, xy = TRUE, na.rm = FALSE)

  # Keep pixels present in any scenario OR within the hull
  keep <- (!is.na(df$present_now)  & df$present_now  == 1L) |
          (!is.na(df$hull_val))                               |
          (!is.na(df$present_ssp2) & df$present_ssp2 == 1L) |
          (!is.na(df$present_ssp3) & df$present_ssp3 == 1L)

  df <- df[keep, ]

  if (nrow(df) > 0) {
    results[[i]] <- data.table(
      species      = sp_name,
      lon          = df$x,
      lat          = df$y,
      present_now  = as.integer(df$present_now),
      present_ssp2 = as.integer(df$present_ssp2),
      present_ssp3 = as.integer(df$present_ssp3),
      within_hull  = !is.na(df$hull_val)
    )
  }

  if (i %% 100 == 0 || i == n_species) {
    elapsed <- (proc.time() - t_start)[["elapsed"]]
    eta     <- elapsed / i * (n_species - i)
    cat(sprintf("[%4d/%d] %-40s  elapsed %s  ETA %s\n",
                i, n_species, sp_name,
                format_time(elapsed), format_time(eta)))
  }
}

# ---- Combine and write Parquet -----------------------------
cat("\nBinding rows...\n")
dt <- rbindlist(results, use.names = TRUE, fill = TRUE)

# Ensure consistent types after fill
dt[, present_now  := as.integer(present_now)]
dt[, present_ssp2 := as.integer(present_ssp2)]
dt[, present_ssp3 := as.integer(present_ssp3)]
dt[, within_hull  := as.logical(within_hull)]

cat(sprintf("Total rows:    %s\n", format(nrow(dt), big.mark = ",")))
cat(sprintf("Total species: %d\n", dt[, uniqueN(species)]))
if (length(skipped) > 0) cat(sprintf("Skipped:       %d species (files absent)\n", length(skipped)))

cat("\nWriting Parquet (snappy compression)...\n")
write_parquet(dt, out_parquet, compression = "snappy")

size_mb <- file.size(out_parquet) / 1024^2
cat(sprintf("\nDone in %s. File: %.1f MB\n  %s\n",
            format_time((proc.time() - t_start)[["elapsed"]]),
            size_mb, out_parquet))
