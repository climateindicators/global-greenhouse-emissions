# Provenance

Every file in this directory is reproduced unmodified from EPA's published
indicator page and its per-figure data downloads. To update the data, replace the
file and rerun `Rscript R/build_data.R`.

## Indicator page

- `source-page.html`  \
  <https://19january2025snapshot.epa.gov/climate-indicators/climate-change-indicators-global-greenhouse-gas-emissions/index.html>  \
  sha256 `816920da8de673e1d8c1b42491854d2cc748204c979fc9b9d96822ff8d9a78d6`

Technical documentation: <https://19january2025snapshot.epa.gov/system/files/documents/2024-12/global-ghg-emissions_td.pdf>

## Figure data

- `global-ghg-emissions_fig-1.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-12/global-ghg-emissions_fig-1.csv>  \
  sha256 `400559187be8a175adb8e8df228b154ff1ea241d972dd25aa2cbfebab520089b`  \
  encoding UTF-8, 6 data rows, columns: `Year`, `Carbon dioxide`, `Methane`, `Nitrous oxide`, `HFCs, PFCs, and SF6`  \
  title: Figure 1. Global Greenhouse Gas Emissions by Gas, 1990-2015  \
  data source: Climate Watch, 2024; web update: December 2024; units: million metric tons CO2e

- `global-ghg-emissions_fig-2.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-12/global-ghg-emissions_fig-2.csv>  \
  sha256 `f35d8ecc94e9802bb0383ed775fe5313dfc11e2bbf329cab55a315bc6258c3c4`  \
  encoding UTF-8, 6 data rows, columns: `Year`, `Energy`, `International transport`, `Agriculture`, `Industrial processes`, `Waste`, `Land-use change and forestry`  \
  title: Figure 2. Global Greenhouse Gas Emissions by Sector, 1990-2015  \
  data source: Climate Watch, 2024; web update: December 2024; units: million metric tons CO2e

- `global-ghg-emissions_fig-3.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-12/global-ghg-emissions_fig-3.csv>  \
  sha256 `84752f6f5b63708554793a3ec63e26f94252b705ba2176fe45595338701cee59`  \
  encoding UTF-8, 32 data rows, columns: `Region`, `East Asia and Pacific`, `Europe and Central Asia`, `United States`, `South Asia`, `Middle East and North Africa`, `Latin America and Caribbean`, `Sub-Saharan Africa`, `Canada`, `Other`  \
  title: Figure 3. Global Carbon Dioxide Emissions by Region, 1990-2021  \
  data source: Climate Watch, 2024; web update: December 2024; units: million metric tons
