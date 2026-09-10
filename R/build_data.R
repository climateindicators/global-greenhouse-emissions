# Build tidy long-format data for the Global Greenhouse Gas Emissions indicator.
#
#   Rscript R/build_data.R
#
# Reads EPA's published figure CSVs in data-raw/ and writes data/*.csv plus
# data/meta.yml. Rerunning with unchanged inputs produces byte-identical output.
# Nothing here touches the network.
#
# Generated as a stub by the build-indicator skill. Each figure below has a
# `todo_reshape()` call standing where its reshape belongs. Replace that line,
# then delete the todo_reshape() helper once no call to it remains.
#
# TO UPDATE THE DATA: drop replacement CSVs into data-raw/ and rerun. Headers
# are asserted, not assumed, so a renamed or reordered column stops the build.

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
})

root <- here::here()
source(file.path(root, "R/utils/epa_csv.R"))
source(file.path(root, "R/utils/write_stable.R"))

raw_dir <- file.path(root, "data-raw")
out_dir <- file.path(root, "data")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- Indicator constants -----------------------------------------------------

INDICATOR <- list(
  name                    = "Global Greenhouse Gas Emissions",
  slug                    = "global-greenhouse-gas-emissions",
  publisher               = "U.S. Environmental Protection Agency",
  source_page             = "https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-global-greenhouse-gas-emissions/index.html",
  technical_documentation = "https://19january2025snapshot.epa.gov/system/files/documents/2024-12/global-ghg-emissions_td.pdf",
  rights                  = "Public domain, work of the U.S. Government (17 U.S.C. 105)"
)

# ---- Figure 1: Global Greenhouse Gas Emissions by Gas, 1990-2015 ----

f1_path <- file.path(raw_dir, "global-ghg-emissions_fig-1.csv")
f1_meta <- read_epa_preamble(f1_path)
f1_raw  <- read_epa_csv(f1_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f1_raw,
  id_cols          = c("Year"),
  expected_headers = c("Carbon dioxide", "Methane", "Nitrous oxide", "HFCs, PFCs, and SF6"),
  what             = "global-ghg-emissions_fig-1.csv"
)

# Wide: one row per year, one column per gas. Pivot the gas columns into a
# gas/value pair; Year becomes year. Every source cell is populated (no
# suppression markers in this file), so the row count is exactly rows * gases.
f1 <- f1_raw %>%
  rename(year = Year) %>%
  pivot_longer(-year, names_to = "gas", values_to = "value")
assert_conservation(
  f1_raw,
  value_cols = setdiff(names(f1_raw), "Year"),
  n_out      = nrow(f1),
  what       = "global-ghg-emissions_fig-1.csv"
)

# The output name below is a placeholder. Rename it for what the figure
# actually carries, the way river_flooding_magnitude.csv does.
write_csv_stable(f1, file.path(out_dir, "global_greenhouse_gas_emissions_fig1.csv"))

# ---- Figure 2: Global Greenhouse Gas Emissions by Sector, 1990-2015 ----

f2_path <- file.path(raw_dir, "global-ghg-emissions_fig-2.csv")
f2_meta <- read_epa_preamble(f2_path)
f2_raw  <- read_epa_csv(f2_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f2_raw,
  id_cols          = c("Year"),
  expected_headers = c("Energy", "International transport", "Agriculture", "Industrial processes", "Waste", "Land-use change and forestry"),
  what             = "global-ghg-emissions_fig-2.csv"
)

# Wide: one row per year, one column per sector. Pivot the sector columns into
# a sector/value pair; Year becomes year.
f2 <- f2_raw %>%
  rename(year = Year) %>%
  pivot_longer(-year, names_to = "sector", values_to = "value")
assert_conservation(
  f2_raw,
  value_cols = setdiff(names(f2_raw), "Year"),
  n_out      = nrow(f2),
  what       = "global-ghg-emissions_fig-2.csv"
)

# The output name below is a placeholder. Rename it for what the figure
# actually carries, the way river_flooding_magnitude.csv does.
write_csv_stable(f2, file.path(out_dir, "global_greenhouse_gas_emissions_fig2.csv"))

# ---- Figure 3: Global Carbon Dioxide Emissions by Region, 1990-2021 ----

f3_path <- file.path(raw_dir, "global-ghg-emissions_fig-3.csv")
f3_meta <- read_epa_preamble(f3_path)
f3_raw  <- read_epa_csv(f3_path)

# All columns are listed as expected headers so a rename or reorder stops the
# build from the first run. When you write the reshape, move the identifier
# columns into id_cols so the split between keys and series is explicit.
assert_headers(
  f3_raw,
  id_cols          = c("Region"),
  expected_headers = c("East Asia and Pacific", "Europe and Central Asia", "United States", "South Asia", "Middle East and North Africa", "Latin America and Caribbean", "Sub-Saharan Africa", "Canada", "Other"),
  what             = "global-ghg-emissions_fig-3.csv"
)

# The source header for this column is literally "Region", but every value in
# it is a year (1990-2021); the region names are the other 9 columns. Renamed
# to year here so the output isn't mislabeled the way EPA's own CSV is.
f3 <- f3_raw %>%
  rename(year = Region) %>%
  pivot_longer(-year, names_to = "region", values_to = "value")
assert_conservation(
  f3_raw,
  value_cols = setdiff(names(f3_raw), "Region"),
  n_out      = nrow(f3),
  what       = "global-ghg-emissions_fig-3.csv"
)

# The output name below is a placeholder. Rename it for what the figure
# actually carries, the way river_flooding_magnitude.csv does.
write_csv_stable(f3, file.path(out_dir, "global_greenhouse_gas_emissions_fig3.csv"))

# ---- Data dictionary ---------------------------------------------------------

col <- function(name, type, description) {
  list(name = name, type = type, description = description)
}

COLUMN_DOCS <- list(
  year = col("year", "integer", "Calendar year."),
  gas = col("gas", "string",
    "Greenhouse gas category, as EPA's chart legend: Carbon dioxide, Methane, Nitrous oxide, or HFCs, PFCs, and SF6."),
  sector = col("sector", "string",
    "Source sector, as EPA's chart legend: Energy, International transport, Agriculture, Industrial processes, Waste, or Land-use change and forestry."),
  region = col("region", "string",
    "World region or country, as EPA's chart legend: East Asia and Pacific, Europe and Central Asia, United States, South Asia, Middle East and North Africa, Latin America and Caribbean, Sub-Saharan Africa, Canada, or Other."),
  value_gas = col("value", "number",
    "Global emissions of the given gas, in million metric tons of CO2 equivalent (CO2e), verbatim from the source file."),
  value_sector = col("value", "number",
    "Global greenhouse gas emissions from the given sector, in million metric tons of CO2 equivalent (CO2e), verbatim from the source file."),
  value_region = col("value", "number",
    "Global carbon dioxide emissions for the given region, in million metric tons, verbatim from the source file.")
)

describe <- function(cols) lapply(cols, function(nm) COLUMN_DOCS[[nm]])

meta <- list(
  indicator = INDICATOR,
  datasets = list(
    list(
      file            = "global_greenhouse_gas_emissions_fig1.csv",
      figure          = "Figure 1",
      figure_title    = f1_meta$title,
      source_file     = "global-ghg-emissions_fig-1.csv",
      source_sha256   = file_sha256(f1_path),
      source_encoding = "UTF-8",
      data_source     = f1_meta$data_source,
      web_update      = f1_meta$web_update,
      unit            = f1_meta$units,
      rows            = nrow(f1),
      columns         = describe(c("year", "gas", "value_gas"))
    ),
    list(
      file            = "global_greenhouse_gas_emissions_fig2.csv",
      figure          = "Figure 2",
      figure_title    = f2_meta$title,
      source_file     = "global-ghg-emissions_fig-2.csv",
      source_sha256   = file_sha256(f2_path),
      source_encoding = "UTF-8",
      data_source     = f2_meta$data_source,
      web_update      = f2_meta$web_update,
      unit            = f2_meta$units,
      rows            = nrow(f2),
      columns         = describe(c("year", "sector", "value_sector"))
    ),
    list(
      file            = "global_greenhouse_gas_emissions_fig3.csv",
      figure          = "Figure 3",
      figure_title    = f3_meta$title,
      source_file     = "global-ghg-emissions_fig-3.csv",
      source_sha256   = file_sha256(f3_path),
      source_encoding = "UTF-8",
      data_source     = f3_meta$data_source,
      web_update      = f3_meta$web_update,
      unit            = f3_meta$units,
      rows            = nrow(f3),
      columns         = describe(c("year", "region", "value_region"))
    )
  )
)

write_yaml_stable(meta, file.path(out_dir, "meta.yml"))

# ---- Verify what was written -------------------------------------------------

written <- list.files(out_dir, pattern = "[.](csv|yml)$", full.names = TRUE)
invisible(lapply(written, assert_clean_output))

cat("\nWrote:\n")
for (p in written) {
  cat(sprintf("  %-34s %8d bytes  %s\n", basename(p), file.size(p), substr(file_sha256(p), 1, 12)))
}
