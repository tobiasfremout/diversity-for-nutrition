# Diversity for Nutrition

R backend for the Diversity for Nutrition tool. Given a location (longitude, latitude) and user-defined filters, the tool identifies plant species that can be grown at that location and returns their nutritional information (edible part, food group).

## How it works

1. **Parse inputs** — convert and validate all parameters arriving as strings
2. **Load data** — read species nutrition data and soil data (from S3 or local)
3. **Load maps** — load present-climate and future-climate SDM rasters for each species
4. **Species analysis** — extract which species are predicted to be suitable at the coordinates, then filter by user inputs (edible parts, food groups etc)
5. **Output** — generate an HTML report and upload it to S3

## Entry point

```r
source("functions.R")

mainNutrition(
  lon            = -49.91,
  lat            = -26.34,
  edible_parts_ID = "5,6",
  food_groups_ID  = "3,15",
  growth_forms_ID = "1",
  species_type_ID = "1",
  within_range    = "yes",
  incl_tentative  = "yes",
  SSP             = "SSP2",
  language_output = "EN"
)
```

All parameters are passed as strings (as received from the web app). See `test_runner.R` for a working example.

## Project structure

```
functions.R              # Entry point — mainNutrition()
nutrition.R              # Orchestrator — process_nutrition()
config.R                 # Runtime config (local vs Lambda/S3)
src/
  libs.R                 # Packages
  io/
    utils.R              # S3/local file I/O (download, upload, load_raster, etc.)
    helpers.R            # Logging, reverse geocoding, CSV reading
  input/
    parse_inputs.R       # Input parsing and type conversion
  data/
    load_data.R          # Load nutrition and soil data
    load_maps.R          # Load present and future SDM rasters
  analysis/
    species_analysis.R   # Extract suitable species, apply filters
```

## Data

Expected data folder structure (S3 bucket: `d4n-data`, default prefix: `D4N_data`):

```
Tables/
  species_nutrition_data.csv
soil_extremes.csv
Maps/
  Presence-absence/         # Present SDMs, one .tif per species
  Presence-absence masked by hull/
  Future/{SSP}/             # Future SDMs, one .tif per species per scenario
  Future masked by hull/{SSP}/
```

## Local development

Set the environment variable `USE_LOCAL_FILES=TRUE` and `LOCAL_DATA_PATH` to your local data directory. The tool will read from and write to the local filesystem instead of S3.

```r
Sys.setenv(USE_LOCAL_FILES = "TRUE")
Sys.setenv(LOCAL_DATA_PATH = "C:/path/to/D4N_data")
```

Each local run writes three files into `local_data/diversity/report_<timestamp>/`:

- `data.json` — structured output (coords, country, region, biome, filters, species table, translation labels).
- `data.js` — same payload as a `window.d4nReport` assignment, consumed by the local viewer.
- `local_viewer.html` — a **dev-only** HTML viewer that renders `data.js` as a table + mini-map. Open this file in your browser right after the run to inspect results visually.

The viewer is intentionally independent from the production report (which lives in the WordPress theme repo). It only exists to validate local runs and is never uploaded to S3 or shown to end users.

## Dependencies

- `terra` — raster operations
- `httr` — reverse geocoding (Nominatim)
- `paws` — AWS S3 (only needed when `USE_LOCAL_FILES=FALSE`)
- `jsonlite` — JSON parsing (test runner)
