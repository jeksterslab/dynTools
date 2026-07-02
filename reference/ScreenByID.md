# Screen IDs Using Dynamic-Data Diagnostics

The function computes ID-level diagnostics, applies rule-based flags,
and returns IDs that are candidates for exclusion or sensitivity
analysis. It is a wrapper around
[`DiagnosticsByID()`](https://github.com/jeksterslab/dynTools/reference/DiagnosticsByID.md),
[`FlagDiagnosticsByID()`](https://github.com/jeksterslab/dynTools/reference/FlagDiagnosticsByID.md),
and
[`GetDropID()`](https://github.com/jeksterslab/dynTools/reference/GetDropID.md).

## Usage

``` r
ScreenByID(
  data,
  id,
  time,
  observed,
  covariates = NULL,
  missing_codes = NULL,
  min_nonmissing = 1L,
  extreme_cut = c(4, 5, 6),
  sd_cut = c(0.1, 0.05),
  time_scale = 1,
  posix_unit = "hours",
  min_observed_rows = 30L,
  min_complete_rows = NULL,
  max_prop_all_missing = 0.95,
  max_gap = NULL,
  max_median_gap = NULL,
  min_sd = 0.05,
  flag_extreme_cut = 6,
  drop_score_cut = 2L,
  flagged_only = TRUE
)
```

## Arguments

- data:

  Data frame. A data frame object of data for potentially multiple
  subjects that contain a column of subject ID numbers (i.e., an ID
  variable), a column indicating subject-specific measurement occasions
  (i.e., a TIME variable), at least one column of observed values.

- id:

  Character string. A character string of the name of the ID variable in
  the data.

- time:

  Character string. A character string of the name of the TIME variable
  in the data.

- observed:

  Character vector. A vector of character strings of the names of the
  observed variables in the data.

- covariates:

  Character vector. A vector of character strings of the names of the
  covariates in the data.

- missing_codes:

  `NULL` or vector. Values to temporarily treat as missing when
  computing diagnostics. The input data are not modified.

- min_nonmissing:

  Positive integer. Minimum number of non-missing observed variables
  required for a row to count as an observed row.

- extreme_cut:

  Numeric vector. Absolute-value cutoffs used to count extreme values.

- sd_cut:

  Numeric vector. Within-ID standard-deviation cutoffs used to count
  low-variance variables.

- time_scale:

  Positive number. Multiplier applied to numeric time gaps. For example,
  use `time_scale = 24` when time is measured in days and gaps should be
  reported in hours.

- posix_unit:

  Character string. Unit for gaps when `time` is a `POSIXt` or `Date`
  variable. Passed to `as.numeric.difftime()`.

- min_observed_rows:

  Positive integer. Minimum number of observed rows expected per ID.

- min_complete_rows:

  `NULL` or positive integer. Minimum number of complete rows expected
  per ID.

- max_prop_all_missing:

  `NULL` or number between 0 and 1. Maximum tolerated proportion of
  all-missing observed rows.

- max_gap:

  `NULL` or positive number. Maximum tolerated observed-row time gap in
  the units used by
  [`DiagnosticsByID()`](https://github.com/jeksterslab/dynTools/reference/DiagnosticsByID.md).

- max_median_gap:

  `NULL` or positive number. Maximum tolerated median observed-row time
  gap in the units used by
  [`DiagnosticsByID()`](https://github.com/jeksterslab/dynTools/reference/DiagnosticsByID.md).

- min_sd:

  Non-negative number. Minimum tolerated within-ID standard deviation
  across observed variables.

- flag_extreme_cut:

  Positive number. Absolute-value cutoff used by
  [`FlagDiagnosticsByID()`](https://github.com/jeksterslab/dynTools/reference/FlagDiagnosticsByID.md).
  This value is added to `extreme_cut` before calling
  [`DiagnosticsByID()`](https://github.com/jeksterslab/dynTools/reference/DiagnosticsByID.md)
  so that the required total-count column is available.

- drop_score_cut:

  Positive integer. IDs with priority scores greater than or equal to
  this value are marked as sensitivity-drop candidates.

- flagged_only:

  Logical. If `TRUE`, return IDs marked as sensitivity-drop candidates.
  If `FALSE`, return all flagged IDs.

## Value

Returns a list with the following elements:

- `diagnostics`:

  Diagnostics with flag columns appended.

- `drop_id`:

  IDs selected by
  [`GetDropID()`](https://github.com/jeksterslab/dynTools/reference/GetDropID.md).

- `keep_id`:

  IDs not in `drop_id`.

- `call`:

  The matched call.

## See also

Other Dynamic Modeling Utility Functions:
[`CheckDynData()`](https://github.com/jeksterslab/dynTools/reference/CheckDynData.md),
[`CombineByIDTime()`](https://github.com/jeksterslab/dynTools/reference/CombineByIDTime.md),
[`DeleteInitialNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteInitialNA.md),
[`DeleteObservedAllNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteObservedAllNA.md),
[`DeltaTByID()`](https://github.com/jeksterslab/dynTools/reference/DeltaTByID.md),
[`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md),
[`DiagnoseDetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DiagnoseDetrendByID.md),
[`DiagnosticsByID()`](https://github.com/jeksterslab/dynTools/reference/DiagnosticsByID.md),
[`DropByID()`](https://github.com/jeksterslab/dynTools/reference/DropByID.md),
[`ElapsedTimeByID()`](https://github.com/jeksterslab/dynTools/reference/ElapsedTimeByID.md),
[`ElapsedTimeByIDCT()`](https://github.com/jeksterslab/dynTools/reference/ElapsedTimeByIDCT.md),
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
[`ResolveCloseTimeByID()`](https://github.com/jeksterslab/dynTools/reference/ResolveCloseTimeByID.md),
[`ResolveDuplicateIDTime()`](https://github.com/jeksterslab/dynTools/reference/ResolveDuplicateIDTime.md),
[`RoundClockTime()`](https://github.com/jeksterslab/dynTools/reference/RoundClockTime.md),
[`ScaleByID()`](https://github.com/jeksterslab/dynTools/reference/ScaleByID.md),
[`SubsetByID()`](https://github.com/jeksterslab/dynTools/reference/SubsetByID.md),
[`SummaryByID()`](https://github.com/jeksterslab/dynTools/reference/SummaryByID.md),
[`TrimInitialRowsByID()`](https://github.com/jeksterslab/dynTools/reference/TrimInitialRowsByID.md)

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
data <- data.frame(
  id = c(1, 1, 1, 2, 2, 2),
  time = c(1, 2, 3, 1, 2, 3),
  y1 = c(1, NA, 3, 1, 1, 1),
  y2 = c(NA, NA, 4, 2, 2, 2)
)

ScreenByID(
  data = data,
  id = "id",
  time = "time",
  observed = c("y1", "y2"),
  min_observed_rows = 3,
  min_sd = 0.05
)
#> $diagnostics
#>   id n_rows n_observed_rows n_complete_rows prop_all_missing
#> 1  1      3               2               1        0.3333333
#> 2  2      3               3               3        0.0000000
#>   n_duplicate_id_time min_time max_time max_obs_gap median_obs_gap mean_obs_gap
#> 1                   0        1        3           2              2            2
#> 2                   0        1        3           1              1            1
#>     miss_y1 n_y1    sd_y1 maxabs_y1 n_abs_gt4_y1 n_abs_gt5_y1 n_abs_gt6_y1
#> 1 0.3333333    2 1.414214         3            0            0            0
#> 2 0.0000000    3 0.000000         1            0            0            0
#>     miss_y2 n_y2 sd_y2 maxabs_y2 n_abs_gt4_y2 n_abs_gt5_y2 n_abs_gt6_y2
#> 1 0.6666667    1    NA         4            0            0            0
#> 2 0.0000000    3     0         2            0            0            0
#>     min_sd median_sd min_sd_variable max_abs_any max_abs_variable
#> 1 1.414214  1.414214              y1           4               y2
#> 2 0.000000  0.000000              y1           2               y2
#>   n_var_sd_lt_0_1 n_var_sd_lt_0_05 n_abs_gt4_total n_abs_gt5_total
#> 1               0                0               0               0
#> 2               2                2               0               0
#>   n_abs_gt6_total flag_low_observed_rows flag_low_complete_rows
#> 1               0                   TRUE                  FALSE
#> 2               0                  FALSE                  FALSE
#>   flag_mostly_all_missing flag_large_gap flag_large_median_gap flag_low_sd
#> 1                   FALSE          FALSE                 FALSE       FALSE
#> 2                   FALSE          FALSE                 FALSE        TRUE
#>   flag_extreme priority_score flag_any drop_sensitivity_candidate flag_reason
#> 1        FALSE              1     TRUE                       TRUE  n_obs_lt_3
#> 2        FALSE              1     TRUE                       TRUE  sd_lt_0.05
#> 
#> $drop_id
#> [1] 1 2
#> 
#> $keep_id
#> numeric(0)
#> 
#> $call
#> ScreenByID(data = data, id = "id", time = "time", observed = c("y1", 
#>     "y2"), min_observed_rows = 3, min_sd = 0.05)
#> 
#> attr(,"class")
#> [1] "dynToolsScreenByID"
```
