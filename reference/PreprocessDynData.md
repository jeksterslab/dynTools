# Preprocess Intensive Longitudinal Data for Dynamic Modeling

The function implements a reproducible preprocessing workflow for
intensive longitudinal data before dynamic model fitting. The workflow
can replace missing-value codes, construct a date-time variable, resolve
exact duplicate ID-time rows, remove initial all-missing rows, create
elapsed time by ID, compute ID-level diagnostics, optionally drop
flagged IDs, optionally insert missing rows on a regular grid, detrend
observed variables by ID, and center or standardize observed variables
by ID.

## Usage

``` r
PreprocessDynData(
  data,
  id,
  observed,
  covariates = NULL,
  date = NULL,
  clock_time = NULL,
  time = NULL,
  tz = "UTC",
  date_formats = c("%m/%d/%y", "%m/%d/%Y", "%Y-%m-%d"),
  invalid = c("NA", "error"),
  datetime_output = "time_obs",
  raw_time_output = "time_raw",
  output_time = "time",
  missing_codes = c(-999, "-999"),
  missing_columns = NULL,
  drop_missing_time = TRUE,
  duplicate_method = c("max_complete", "first", "last"),
  delete_initial_na = TRUE,
  initial_min_nonmissing = 1L,
  elapsed_units = "days",
  elapsed_origin = c("by_id", "global"),
  elapsed_input_units = NULL,
  screen = TRUE,
  drop_id = NULL,
  drop_flagged = FALSE,
  min_observed_rows = 30L,
  min_complete_rows = NULL,
  max_prop_all_missing = 0.95,
  max_gap = NULL,
  max_median_gap = NULL,
  min_sd = 0.05,
  flag_extreme_cut = 6,
  drop_score_cut = 2L,
  min_nonmissing = 1L,
  extreme_cut = c(4, 5, 6),
  sd_cut = c(0.1, 0.05),
  screen_time_scale = 24,
  posix_unit = "hours",
  regularize = FALSE,
  delta_t = NULL,
  grid = c("by_id", "global"),
  regularize_method = c("preserve", "snap"),
  detrend = TRUE,
  degree = 1L,
  keep_mean = TRUE,
  warn_skipped = TRUE,
  drop_skipped_ids = TRUE,
  center = TRUE,
  scale = TRUE,
  obs_skip = NULL,
  cov_skip = NULL,
  keep_raw_time = FALSE,
  keep_datetime = TRUE,
  final_diagnostics = TRUE,
  return_list = TRUE
)
```

## Arguments

- data:

  Data frame.

- id:

  Character string. Name of the ID variable.

- observed:

  Character vector. Names of observed variables to preprocess.

- covariates:

  Character vector or `NULL`. Names of covariates to retain and
  optionally center or scale.

- date:

  Character string or `NULL`. Name of the date variable. Use with
  `clock_time` to construct clock time.

- clock_time:

  Character string or `NULL`. Name of the within-day clock-time
  variable. Use with `date`.

- time:

  Character string or `NULL`. Name of an existing time variable. Used
  when `date` and `clock_time` are not supplied.

- tz:

  Character string. Time zone passed to
  [`MakeClockTime()`](https://github.com/jeksterslab/dynTools/reference/MakeClockTime.md).

- date_formats:

  Character vector. Date formats passed to
  [`MakeClockTime()`](https://github.com/jeksterslab/dynTools/reference/MakeClockTime.md).

- invalid:

  Character string. Invalid clock-time handling passed to
  [`MakeClockTime()`](https://github.com/jeksterslab/dynTools/reference/MakeClockTime.md).

- datetime_output:

  Character string. Name of the constructed `POSIXct` date-time variable
  when `date` and `clock_time` are supplied.

- raw_time_output:

  Character string. Name of the numeric raw-time variable used for
  duplicate resolution.

- output_time:

  Character string. Name of the elapsed-time variable used for modeling.

- missing_codes:

  `NULL` or vector. Missing-value codes to replace with `NA`.

- missing_columns:

  Character vector or `NULL`. Columns where missing-value codes should
  be replaced. If `NULL`, the replacement is applied to `observed` and
  `covariates`.

- drop_missing_time:

  Logical. If `TRUE`, remove rows with missing constructed/raw time
  before duplicate resolution.

- duplicate_method:

  Character string. Method passed to
  [`ResolveDuplicateIDTime()`](https://github.com/jeksterslab/dynTools/reference/ResolveDuplicateIDTime.md).

- delete_initial_na:

  Logical. If `TRUE`, remove leading rows with too few observed values
  within ID.

- initial_min_nonmissing:

  Positive integer. Minimum number of non-missing observed variables
  required in the first retained row within ID. Use `length(observed)`
  to mimic the stricter behavior of
  [`DeleteInitialNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteInitialNA.md).

- elapsed_units:

  Character string. Units for elapsed time passed to
  [`ElapsedTimeByID()`](https://github.com/jeksterslab/dynTools/reference/ElapsedTimeByID.md).

- elapsed_origin:

  Character string. Origin passed to
  [`ElapsedTimeByID()`](https://github.com/jeksterslab/dynTools/reference/ElapsedTimeByID.md).

- elapsed_input_units:

  Character string or `NULL`. Units of numeric raw time passed to
  [`ElapsedTimeByID()`](https://github.com/jeksterslab/dynTools/reference/ElapsedTimeByID.md).

- screen:

  Logical. If `TRUE`, compute ID-level diagnostics and drop candidates
  before optional regularization, detrending, and scaling.

- drop_id:

  Vector or `NULL`. IDs to remove regardless of diagnostic flags.

- drop_flagged:

  Logical. If `TRUE`, remove IDs selected by
  [`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md).
  If `FALSE`, return the candidates but keep them in the processed data.

- min_observed_rows:

  Positive number. Minimum number of rows with at least `min_nonmissing`
  observed variables required for each ID. Passed to
  [`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md).

- min_complete_rows:

  Positive number or `NULL`. Minimum number of complete observed rows
  required for each ID. Passed to
  [`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md).

- max_prop_all_missing:

  Numeric value in `[0, 1]` or `NULL`. Maximum allowed proportion of
  rows with all observed variables missing for each ID. Passed to
  [`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md).

- max_gap:

  Positive number or `NULL`. Maximum allowed observed-time gap for each
  ID. Passed to
  [`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md).

- max_median_gap:

  Positive number or `NULL`. Maximum allowed median observed-time gap
  for each ID. Passed to
  [`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md).

- min_sd:

  Non-negative number or `NULL`. Minimum allowed within-ID standard
  deviation across observed variables. Passed to
  [`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md).

- flag_extreme_cut:

  Positive number. Absolute standardized-value cutoff used to flag
  extreme values. Passed to
  [`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md).

- drop_score_cut:

  Positive number. Priority-score cutoff used by
  [`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md)
  when `flagged_only = TRUE`.

- min_nonmissing:

  Positive integer. Minimum number of non-missing observed variables
  defining an observed row. Passed to
  [`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md).

- extreme_cut:

  Numeric vector. Extreme-value cut points used by
  [`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md).

- sd_cut:

  Numeric vector. Low-variability cut points used by
  [`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md).

- screen_time_scale:

  Positive number. Multiplier applied to time gaps in
  [`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md).

- posix_unit:

  Character string. Unit used for `POSIXct` time-gap calculations in
  [`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md).

- regularize:

  Logical. If `TRUE`, call
  [`RegularizeTimeByID()`](https://github.com/jeksterslab/dynTools/reference/RegularizeTimeByID.md).
  Continuous-time models that handle unequal intervals usually do not
  require this step.

- delta_t:

  Positive number or `NULL`. Time interval passed to
  [`RegularizeTimeByID()`](https://github.com/jeksterslab/dynTools/reference/RegularizeTimeByID.md)
  when `regularize = TRUE`.

- grid:

  Character string. Grid type passed to
  [`RegularizeTimeByID()`](https://github.com/jeksterslab/dynTools/reference/RegularizeTimeByID.md).

- regularize_method:

  Character string. Method passed to
  [`RegularizeTimeByID()`](https://github.com/jeksterslab/dynTools/reference/RegularizeTimeByID.md).

- detrend:

  Logical. If `TRUE`, call
  [`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md).

- degree:

  Non-negative integer. Polynomial degree passed to
  [`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md).

- keep_mean:

  Logical. Passed to
  [`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md).

- warn_skipped:

  Logical. Passed to
  [`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md).

- drop_skipped_ids:

  Logical. Passed to
  [`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md).

- center:

  Logical. If `TRUE`, call
  [`ScaleByID()`](https://github.com/jeksterslab/dynTools/reference/ScaleByID.md).

- scale:

  Logical. If `TRUE`, standardize by ID. If `FALSE`, only mean-center by
  ID. Ignored when `center = FALSE`.

- obs_skip, cov_skip:

  Character vectors or `NULL`. Variables to skip when centering or
  scaling.

- keep_raw_time:

  Logical. If `FALSE`, remove `raw_time_output` from the returned data.

- keep_datetime:

  Logical. If `FALSE`, remove `datetime_output` from the returned data.

- final_diagnostics:

  Logical. If `TRUE`, compute diagnostics on the final processed data.

- return_list:

  Logical. If `TRUE`, return a list with data, diagnostics, and dropped
  IDs. If `FALSE`, return only the processed data.

## Value

If `return_list = TRUE`, returns a list with elements `data`,
`diagnostics`, `final_diagnostics`, `drop_id`, `flagged_id`,
`manual_drop_id`, and `call`. If `return_list = FALSE`, returns the
processed data frame.

## See also

Other Dynamic Modeling Utility Functions:
[`CheckDynData()`](https://github.com/jeksterslab/dynTools/reference/CheckDynData.md),
[`CombineByIDTime()`](https://github.com/jeksterslab/dynTools/reference/CombineByIDTime.md),
[`DeleteInitialNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteInitialNA.md),
[`DeltaTByID()`](https://github.com/jeksterslab/dynTools/reference/DeltaTByID.md),
[`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md),
[`DiagnosticsByID()`](https://github.com/jeksterslab/dynTools/reference/DiagnosticsByID.md),
[`DropByID()`](https://github.com/jeksterslab/dynTools/reference/DropByID.md),
[`ElapsedTimeByID()`](https://github.com/jeksterslab/dynTools/reference/ElapsedTimeByID.md),
[`FilterByID()`](https://github.com/jeksterslab/dynTools/reference/FilterByID.md),
[`FilterObservedRows()`](https://github.com/jeksterslab/dynTools/reference/FilterObservedRows.md),
[`FlagDiagnosticsByID()`](https://github.com/jeksterslab/dynTools/reference/FlagDiagnosticsByID.md),
[`GetDropID()`](https://github.com/jeksterslab/dynTools/reference/GetDropID.md),
[`GetObservedInitial()`](https://github.com/jeksterslab/dynTools/reference/GetObservedInitial.md),
[`InitialNA()`](https://github.com/jeksterslab/dynTools/reference/InitialNA.md),
[`InsertNA()`](https://github.com/jeksterslab/dynTools/reference/InsertNA.md),
[`LagByID()`](https://github.com/jeksterslab/dynTools/reference/LagByID.md),
[`MakeClockTime()`](https://github.com/jeksterslab/dynTools/reference/MakeClockTime.md),
[`PlotByID()`](https://github.com/jeksterslab/dynTools/reference/PlotByID.md),
[`RegularizeTimeByID()`](https://github.com/jeksterslab/dynTools/reference/RegularizeTimeByID.md),
[`ReplaceMissingCode()`](https://github.com/jeksterslab/dynTools/reference/ReplaceMissingCode.md),
[`ResolveDuplicateIDTime()`](https://github.com/jeksterslab/dynTools/reference/ResolveDuplicateIDTime.md),
[`RoundClockTime()`](https://github.com/jeksterslab/dynTools/reference/RoundClockTime.md),
[`ScaleByID()`](https://github.com/jeksterslab/dynTools/reference/ScaleByID.md),
[`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md),
[`SubsetByID()`](https://github.com/jeksterslab/dynTools/reference/SubsetByID.md),
[`SummaryByID()`](https://github.com/jeksterslab/dynTools/reference/SummaryByID.md),
[`TrimInitialRowsByID()`](https://github.com/jeksterslab/dynTools/reference/TrimInitialRowsByID.md)

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
data <- data.frame(
  id = c(1, 1, 1, 2, 2, 2),
  date = rep("2020-01-01", 6),
  clock = c("08:00", "09:00", "10:00", "08:00", "09:00", "10:00"),
  y1 = c(1, NA, 3, 1, 1, 1),
  y2 = c(NA, 2, 4, 2, 2, 2)
)

PreprocessDynData(
  data = data,
  id = "id",
  date = "date",
  clock_time = "clock",
  observed = c("y1", "y2"),
  min_observed_rows = 3,
  detrend = FALSE,
  center = FALSE
)
#> $data
#>   id       time y1 y2
#> 1  1 0.00000000  1 NA
#> 2  1 0.04166667 NA  2
#> 3  1 0.08333333  3  4
#> 4  2 0.00000000  1  2
#> 5  2 0.04166667  1  2
#> 6  2 0.08333333  1  2
#> 
#> $diagnostics
#>   id n_rows n_observed_rows n_complete_rows prop_all_missing
#> 1  1      3               3               1                0
#> 2  2      3               3               3                0
#>   n_duplicate_id_time min_time   max_time max_obs_gap median_obs_gap
#> 1                   0        0 0.08333333           1              1
#> 2                   0        0 0.08333333           1              1
#>   mean_obs_gap   miss_y1 n_y1    sd_y1 maxabs_y1 n_abs_gt4_y1 n_abs_gt5_y1
#> 1            1 0.3333333    2 1.414214         3            0            0
#> 2            1 0.0000000    3 0.000000         1            0            0
#>   n_abs_gt6_y1   miss_y2 n_y2    sd_y2 maxabs_y2 n_abs_gt4_y2 n_abs_gt5_y2
#> 1            0 0.3333333    2 1.414214         4            0            0
#> 2            0 0.0000000    3 0.000000         2            0            0
#>   n_abs_gt6_y2   min_sd median_sd min_sd_variable max_abs_any max_abs_variable
#> 1            0 1.414214  1.414214              y1           4               y2
#> 2            0 0.000000  0.000000              y1           2               y2
#>   n_var_sd_lt_0_1 n_var_sd_lt_0_05 n_abs_gt4_total n_abs_gt5_total
#> 1               0                0               0               0
#> 2               2                2               0               0
#>   n_abs_gt6_total flag_low_observed_rows flag_low_complete_rows
#> 1               0                  FALSE                  FALSE
#> 2               0                  FALSE                  FALSE
#>   flag_mostly_all_missing flag_large_gap flag_large_median_gap flag_low_sd
#> 1                   FALSE          FALSE                 FALSE       FALSE
#> 2                   FALSE          FALSE                 FALSE        TRUE
#>   flag_extreme priority_score flag_any drop_sensitivity_candidate flag_reason
#> 1        FALSE              0    FALSE                      FALSE            
#> 2        FALSE              1     TRUE                       TRUE  sd_lt_0.05
#> 
#> $final_diagnostics
#>   id n_rows n_observed_rows n_complete_rows prop_all_missing
#> 1  1      3               3               1                0
#> 2  2      3               3               3                0
#>   n_duplicate_id_time min_time   max_time max_obs_gap median_obs_gap
#> 1                   0        0 0.08333333           1              1
#> 2                   0        0 0.08333333           1              1
#>   mean_obs_gap   miss_y1 n_y1    sd_y1 maxabs_y1 n_abs_gt4_y1 n_abs_gt5_y1
#> 1            1 0.3333333    2 1.414214         3            0            0
#> 2            1 0.0000000    3 0.000000         1            0            0
#>   n_abs_gt6_y1   miss_y2 n_y2    sd_y2 maxabs_y2 n_abs_gt4_y2 n_abs_gt5_y2
#> 1            0 0.3333333    2 1.414214         4            0            0
#> 2            0 0.0000000    3 0.000000         2            0            0
#>   n_abs_gt6_y2   min_sd median_sd min_sd_variable max_abs_any max_abs_variable
#> 1            0 1.414214  1.414214              y1           4               y2
#> 2            0 0.000000  0.000000              y1           2               y2
#>   n_var_sd_lt_0_1 n_var_sd_lt_0_05 n_abs_gt4_total n_abs_gt5_total
#> 1               0                0               0               0
#> 2               2                2               0               0
#>   n_abs_gt6_total
#> 1               0
#> 2               0
#> 
#> $drop_id
#> NULL
#> 
#> $flagged_id
#> [1] 2
#> 
#> $manual_drop_id
#> NULL
#> 
#> $call
#> PreprocessDynData(data = data, id = "id", observed = c("y1", 
#>     "y2"), date = "date", clock_time = "clock", min_observed_rows = 3, 
#>     detrend = FALSE, center = FALSE)
#> 
#> attr(,"class")
#> [1] "dynToolsPreprocessDynData"
```
