# Flag Potentially Problematic IDs

The function adds rule-based flags to the output of
[`DiagnosticsByID()`](https://github.com/jeksterslab/dynTools/reference/DiagnosticsByID.md).
It is intended for sensitivity checks before fitting dynamic models.

## Usage

``` r
FlagDiagnosticsByID(
  x,
  min_observed_rows = 30L,
  min_complete_rows = NULL,
  max_prop_all_missing = 0.95,
  max_gap = NULL,
  max_median_gap = NULL,
  min_sd = 0.05,
  extreme_cut = 6,
  drop_score_cut = 2L
)
```

## Arguments

- x:

  Data frame returned by
  [`DiagnosticsByID()`](https://github.com/jeksterslab/dynTools/reference/DiagnosticsByID.md).

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

- extreme_cut:

  Positive number. Absolute-value cutoff used to flag extreme
  observations.

- drop_score_cut:

  Positive integer. IDs with priority scores greater than or equal to
  this value are marked as sensitivity-drop candidates.

## Value

Returns `x` with flag columns appended.

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
  time = c(1, 2, 3, 1, 2, 3),
  y1 = c(1, NA, 3, 1, 1, 1),
  y2 = c(NA, NA, 4, 2, 2, 2)
)

diagnostics <- DiagnosticsByID(
  data = data,
  id = "id",
  time = "time",
  observed = c("y1", "y2")
)

FlagDiagnosticsByID(
  x = diagnostics,
  min_observed_rows = 3,
  min_sd = 0.05
)
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
```
