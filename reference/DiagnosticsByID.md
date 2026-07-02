# ID-Level Diagnostics for Dynamic Modeling Data

The function computes ID-level diagnostics for intensive longitudinal
data. Diagnostics include the number of observed rows, number of
complete rows, proportion of all-missing observed rows, duplicate
ID-time rows, time gaps, within-ID standard deviations, and counts of
extreme observed values.

## Usage

``` r
DiagnosticsByID(
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
  posix_unit = "hours"
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

## Value

Returns a data frame with one row per ID.

## See also

Other Dynamic Modeling Utility Functions:
[`CheckDynData()`](https://github.com/jeksterslab/dynTools/reference/CheckDynData.md),
[`CombineByIDTime()`](https://github.com/jeksterslab/dynTools/reference/CombineByIDTime.md),
[`DeleteInitialNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteInitialNA.md),
[`DeleteObservedAllNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteObservedAllNA.md),
[`DeltaTByID()`](https://github.com/jeksterslab/dynTools/reference/DeltaTByID.md),
[`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md),
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

DiagnosticsByID(
  data = data,
  id = "id",
  time = "time",
  observed = c("y1", "y2")
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
#>   n_abs_gt6_total
#> 1               0
#> 2               0
```
