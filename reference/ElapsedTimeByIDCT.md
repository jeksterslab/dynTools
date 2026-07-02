# Create CT-Scaled Elapsed Time by ID

The function creates an elapsed-time variable within ID and rescales it
for continuous-time state space modeling. The rescaling divides elapsed
time by a typical positive consecutive time interval so that the typical
`delta_t` is approximately 1.

## Usage

``` r
ElapsedTimeByIDCT(
  data,
  id,
  time,
  output = "time_ct",
  units = "hours",
  origin = c("by_id", "global"),
  input_units = NULL,
  scale = c("mean_dt", "median_dt"),
  scale_value = NULL,
  replace = FALSE
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

- output:

  Character string. Name of the elapsed-time variable.

- units:

  Character string. Units for the output elapsed time.

- origin:

  Character string. If `origin = "by_id"`, each ID's origin is its own
  minimum non-missing time. If `origin = "global"`, all IDs use the
  global minimum non-missing time.

- input_units:

  Character string or `NULL`. Units of numeric input time. If `NULL`,
  numeric time is assumed to already be in the desired output scale and
  only subtraction is performed.

- scale:

  Character string. Method used to compute the time-scaling divisor. If
  `scale = "mean_dt"`, the divisor is the mean positive consecutive
  elapsed-time interval. If `scale = "median_dt"`, the divisor is the
  median positive consecutive elapsed-time interval.

- scale_value:

  Numeric or `NULL`. Optional user-supplied positive scaling divisor in
  the elapsed-time `units`. If supplied, this value is used instead of
  estimating the divisor from the data.

- replace:

  Logical. If `TRUE`, replace the original `time` variable. If `FALSE`,
  append `output`.

## Value

Returns a data frame. The returned data frame has an attribute named
`"time_ct_scale"` containing the scaling information.

## Details

This is useful for continuous-time models because the units of time are
arbitrary, but poorly scaled time can lead to drift parameters that are
very large or very small.

The minimum positive consecutive interval is reported as a diagnostic
but is not used as a scaling option. The goal is to make the typical
consecutive interval approximately 1, not the smallest interval.

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
  id = c(1, 1, 2, 2),
  datetime = as.POSIXct(
    c(
      "2020-01-01 00:00:00",
      "2020-01-01 06:00:00",
      "2020-01-03 12:00:00",
      "2020-01-04 00:00:00"
    ),
    tz = "UTC"
  )
)

data_ct <- ElapsedTimeByIDCT(
  data = data,
  id = "id",
  time = "datetime",
  output = "time_ct",
  units = "hours",
  scale = "mean_dt"
)

attr(data_ct, "time_ct_scale")
#> $variable
#> [1] "time_ct"
#> 
#> $original_units
#> [1] "hours"
#> 
#> $scale
#> [1] "mean_dt"
#> 
#> $scale_value
#> [1] 9
#> 
#> $mean_dt_original_units
#> [1] 9
#> 
#> $median_dt_original_units
#> [1] 9
#> 
#> $min_dt_original_units
#> [1] 6
#> 
#> $max_dt_original_units
#> [1] 12
#> 
#> $n_dt
#> [1] 2
#> 
#> $n_positive_dt
#> [1] 2
#> 
#> $interpretation
#> [1] "1 CT time unit = 9 hours."
#> 
```
