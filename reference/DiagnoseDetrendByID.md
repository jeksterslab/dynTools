# Diagnose Detrended Variables by ID

The function computes post-detrending diagnostics by ID for observed
variables. It is intended to be used after detrending and before
within-ID scaling. The function reports within-ID variability,
missingness, non-finite values, and the largest standardized value that
would be produced by within-ID scaling.

## Usage

``` r
DiagnoseDetrendByID(
  data,
  id,
  time,
  observed,
  sd_min = 0.1,
  z_cut = 6,
  min_n = 3L,
  flagged_only = FALSE
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

- sd_min:

  Numeric scalar or `NULL`. Minimum acceptable within-ID standard
  deviation after detrending. If `NULL`, low-SD flagging is skipped.

- z_cut:

  Numeric scalar. Absolute standardized-value threshold used to flag
  potentially extreme values after within-ID scaling.

- min_n:

  Positive integer. Minimum number of finite observations required
  within each ID-variable combination.

- flagged_only:

  Logical. If `TRUE`, return only flagged ID-variable combinations. If
  `FALSE`, return all ID-variable combinations.

## Value

Returns a data frame with one row per ID-variable combination.

## Details

This is useful for identifying ID-variable combinations that may produce
very large standardized values because of outlying detrended
observations or very small within-ID variability.

## See also

Other Dynamic Modeling Utility Functions:
[`CheckDynData()`](https://github.com/jeksterslab/dynTools/reference/CheckDynData.md),
[`CombineByIDTime()`](https://github.com/jeksterslab/dynTools/reference/CombineByIDTime.md),
[`DeleteInitialNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteInitialNA.md),
[`DeleteObservedAllNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteObservedAllNA.md),
[`DeltaTByID()`](https://github.com/jeksterslab/dynTools/reference/DeltaTByID.md),
[`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md),
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
[`ScreenByID()`](https://github.com/jeksterslab/dynTools/reference/ScreenByID.md),
[`SubsetByID()`](https://github.com/jeksterslab/dynTools/reference/SubsetByID.md),
[`SummaryByID()`](https://github.com/jeksterslab/dynTools/reference/SummaryByID.md),
[`TrimInitialRowsByID()`](https://github.com/jeksterslab/dynTools/reference/TrimInitialRowsByID.md)

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
data <- data.frame(
  id = rep(1:2, each = 5),
  time = rep(1:5, times = 2),
  y1 = c(1, 2, 3, 4, 20, 2, 2, 2, 2, 2),
  y2 = c(5, 4, 3, 2, 1, 1, 1, 1, 1, 2)
)

DiagnoseDetrendByID(
  data = data,
  id = "id",
  time = "time",
  observed = c("y1", "y2"),
  z_cut = 3
)
#>   id variable n_total n_finite n_missing n_na n_nan n_inf mean        sd min
#> 1  1       y1       5        5         0    0     0     0  6.0 7.9056942   1
#> 2  1       y2       5        5         0    0     0     0  3.0 1.5811388   1
#> 3  2       y1       5        5         0    0     0     0  2.0 0.0000000   2
#> 4  2       y2       5        5         0    0     0     0  1.2 0.4472136   1
#>   max range max_abs min_z_after_scaling max_z_after_scaling
#> 1  20    19      20          -0.6324555            1.770875
#> 2   5     4       5          -1.2649111            1.264911
#> 3   2     0       2           0.0000000            0.000000
#> 4   2     1       2          -0.4472136            1.788854
#>   max_abs_z_after_scaling time_max_abs_z value_max_abs_z row_max_abs_z
#> 1                1.770875              5              20             5
#> 2                1.264911              1               5             1
#> 3                0.000000              1               2             6
#> 4                1.788854              5               2            10
#>   flag_low_n flag_nonfinite flag_zero_sd flag_low_sd flag_extreme_z  flag
#> 1      FALSE          FALSE        FALSE       FALSE          FALSE FALSE
#> 2      FALSE          FALSE        FALSE       FALSE          FALSE FALSE
#> 3      FALSE          FALSE         TRUE       FALSE          FALSE  TRUE
#> 4      FALSE          FALSE        FALSE       FALSE          FALSE FALSE
```
