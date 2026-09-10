# Regression checks on the generated data for the Global Greenhouse Gas Emissions indicator.
#
#   Rscript tests/test-data.R
#
# The checks below are shape-independent: they hold whatever the reshape in
# R/build_data.R turns each figure into. Value snapshots, which pin the actual
# numbers so a data update fails loudly instead of passing silently, are the
# TODO at the bottom.

setwd(here::here())
source("R/utils/write_stable.R")

# Keeps the dictionary check readable when a meta.yml field is absent altogether.
`%||%` <- function(a, b) if (is.null(a)) b else a

failures <- character()
check <- function(label, ok) {
  ok <- isTRUE(ok)
  cat(sprintf("  [%s] %s\n", if (ok) "PASS" else "FAIL", label))
  if (!ok) failures <<- c(failures, label)
  invisible(ok)
}

rd <- function(f) {
  readr::read_csv(file.path("data", f),
                  col_types = readr::cols(.default = readr::col_character()),
                  na = character(), progress = FALSE)
}

meta <- yaml::read_yaml("data/meta.yml")

cat("\nData dictionary\n")
check("meta.yml documents 3 dataset(s)", length(meta$datasets) == 3L)
check("meta.yml has no timestamp",
      !any(grepl("\\d{4}-\\d{2}-\\d{2}T|Sys\\.time|generated_at",
                 readLines("data/meta.yml", warn = FALSE))))

for (ds in meta$datasets) {
  df   <- rd(ds$file)
  cols <- vapply(ds$columns, function(x) x$name, character(1))
  check(sprintf("%s: meta.yml lists the columns the file actually has", ds$file),
        identical(cols, names(df)))
  check(sprintf("%s: meta.yml row count matches the file", ds$file),
        identical(as.integer(ds$rows), nrow(df)))
  check(sprintf("%s: every column has a type and a description", ds$file),
        all(vapply(ds$columns, function(x) nzchar(x$type %||% "") && nzchar(x$description %||% ""), logical(1))))
  check(sprintf("%s: source file is still present and unchanged", ds$file),
        identical(file_sha256(file.path("data-raw", ds$source_file)), ds$source_sha256))
  check(sprintf("%s: no blank rows", ds$file), nrow(df) > 0L)
}

cat("\nFile hygiene\n")
for (f in list.files("data", pattern = "[.](csv|yml)$", full.names = TRUE)) {
  check(sprintf("%s is UTF-8, LF, no BOM, no mojibake", basename(f)),
        tryCatch({ assert_clean_output(f); TRUE },
                 error = function(e) { cat("      ", conditionMessage(e), "\n"); FALSE }))
}

cat("\nValue snapshots\n")

# Compared as strings, not as.numeric(), so a change in trailing precision
# (e.g. EPA re-publishing 920.42 as 920.420) fails here instead of silently
# rounding away.
snapshot_row <- function(df, i, expected, what) {
  actual <- as.character(unlist(df[i, ], use.names = FALSE))
  check(sprintf("%s: row %d is %s", what, i, paste(expected, collapse = "|")),
        identical(actual, expected))
}
snapshot_extreme <- function(df, which_fn, expected_value, what, label) {
  v <- as.numeric(df$value)
  i <- which_fn(v)
  check(sprintf("%s: %s value is %s (row %d)", what, label, expected_value, i),
        identical(df$value[i], expected_value))
}

f1 <- rd("global_greenhouse_gas_emissions_fig1.csv")
check("fig1: 24 rows", nrow(f1) == 24L)
snapshot_row(f1, 1, c("1990", "Carbon dioxide", "23060.38"), "fig1")
snapshot_row(f1, 24, c("2015", "HFCs, PFCs, and SF6", "1000.64"), "fig1")
snapshot_extreme(f1, which.min, "302.21", "fig1", "min")
snapshot_extreme(f1, which.max, "34686.31", "fig1", "max")

f2 <- rd("global_greenhouse_gas_emissions_fig2.csv")
check("fig2: 36 rows", nrow(f2) == 36L)
snapshot_row(f2, 1, c("1990", "Energy", "22726.95"), "fig2")
snapshot_row(f2, 36, c("2015", "Land-use change and forestry", "920.42"), "fig2")
snapshot_extreme(f2, which.min, "637.9", "fig2", "min")
snapshot_extreme(f2, which.max, "34962.5", "fig2", "max")

f3 <- rd("global_greenhouse_gas_emissions_fig3.csv")
check("fig3: 288 rows", nrow(f3) == 288L)
snapshot_row(f3, 1, c("1990", "East Asia and Pacific", "4426.4"), "fig3")
snapshot_row(f3, 288, c("2021", "Other", "407.19"), "fig3")
snapshot_extreme(f3, which.min, "246.12", "fig3", "min")
snapshot_extreme(f3, which.max, "15603.66", "fig3", "max")

cat("\n")
if (length(failures)) {
  cat(sprintf("%d FAILED:\n", length(failures)))
  for (f in failures) cat("  -", f, "\n")
  quit(status = 1L)
}
cat("All data checks passed.\n")
