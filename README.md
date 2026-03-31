# Diversity for Nutrition

R backend for the Diversity for Nutrition tool. Given a geographic coordinate and user-defined filters, it identifies plant species that are predicted to grow at that location and returns their nutritional information.

## How it works

1. **Parse inputs** — convert and validate all parameters arriving as strings
2. **Load data** — read species nutrition data and soil data (from S3 or local)
3. **Load maps** — load present-climate and future-climate SDM rasters for each species
4. **Species analysis** — extract which species are predicted present at the coordinates, then filter by user inputs
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

## Parameters

| Parameter | Description | Values |
|---|---|---|
| `lon`, `lat` | Coordinates | Decimal degrees |
| `edible_parts_ID` | Comma-separated edible part IDs to include | e.g. `"5,6"` or `"NULL"` |
| `food_groups_ID` | Comma-separated food group IDs to include | e.g. `"3,15"` or `"NULL"` |
| `growth_forms_ID` | Comma-separated growth form IDs to include | e.g. `"1"` or `"NULL"` |
| `species_type_ID` | Wild, cultivated, or both | `"1"` |
| `within_range` | Use hull-masked maps (within native range only) | `"yes"` / `"no"` |
| `incl_tentative` | Include tentative plant part / food group classifications | `"yes"` / `"no"` |
| `SSP` | Climate scenario for future maps | `"SSP2"`, etc. |
| `language_output` | Output language | `"EN"`, `"ES"`, `"FR"`, `"VI"`, `"LO"` |

## Project structure

```
functions.R              # Entry point — mainNutrition()
nutrition.R              # Orchestrator — process_nutrition()
config.R                 # Runtime config (local vs Lambda/S3)
src/
  libs.R                 # Package dependencies
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

Expected data folder structure (S3 bucket: `diversity-for-nutrition`, default prefix: `diversity-for-nutrition-data/Data`):

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
Sys.setenv(LOCAL_DATA_PATH = "C:/path/to/diversity-for-nutrition-data")
```

## Dependencies

- `terra` — raster operations
- `httr` — reverse geocoding (Nominatim)
- `paws` — AWS S3 (only needed when `USE_LOCAL_FILES=FALSE`)
- `jsonlite` — JSON parsing (test runner)
