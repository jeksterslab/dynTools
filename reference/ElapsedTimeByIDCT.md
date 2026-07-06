# Create CT-Scaled Elapsed Time by ID

The function creates an elapsed-time variable within ID and rescales it
for continuous-time state-space modeling. The rescaling divides elapsed
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
`"time_ct_scale"` containing the scaling information, time-scale
interpretation, and conversion multipliers for drift and diffusion
parameters.

## Details

This scaling is motivated by the continuous-time dynamic structural
equation modeling recommendation to use a time scale for which the
average distance between consecutive observations is approximately 1.
The goal is numerical stability: drift parameters are directly
multiplied by time, so poorly scaled time can make drift estimates very
large or very small.

The `mean_dt` option follows this recommendation directly by using the
empirical mean positive consecutive interval as the time-scaling
divisor. The `median_dt` option is a robust alternative that makes the
typical consecutive interval, rather than the arithmetic average
interval, approximately 1.

This scaling can improve numerical optimization because the drift and
diffusion parameters are estimated with respect to a better-scaled time
variable. However, the resulting model parameters are interpreted per
CT-scaled time unit, not per original time unit.

If the original elapsed time is measured in the requested `units` and
the scaling divisor is \\c\\, then

\$\$ t\_{\mathrm{ct}} = t\_{\mathrm{original}} / c. \$\$

Consequently, drift and diffusion covariance parameters estimated using
\\t\_{\mathrm{ct}}\\ are on the CT-scaled time scale:

\$\$ \Phi\_{\mathrm{ct}} = c \Phi\_{\mathrm{original}}, \$\$

and, for a diffusion covariance or intensity matrix,

\$\$ \Sigma\_{\mathrm{ct}} = c \Sigma\_{\mathrm{original}}. \$\$

To express estimates back in the original time units, divide drift and
diffusion covariance/intensity estimates by the stored `scale_value`. If
the diffusion parameter is a standard deviation or Cholesky factor
rather than a covariance/intensity matrix, divide by
`sqrt(scale_value)`.

The minimum positive consecutive interval is reported as a diagnostic
but is not used as a scaling option. The goal is to make the typical
consecutive interval approximately 1, not the smallest interval.

## References

Asparouhov, T., & Muthen, B. (2024). Continuous Time Dynamic Structural
Equation Models. Muthen & Muthen.

## See also

Other Dynamic Modeling Utility Functions:
[`CheckDynData()`](https://github.com/jeksterslab/dynTools/reference/CheckDynData.md),
[`CombineByIDTime()`](https://github.com/jeksterslab/dynTools/reference/CombineByIDTime.md),
[`DeleteInitialNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteInitialNA.md),
[`DeleteObservedAllNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteObservedAllNA.md),
[`DeltaTByID()`](https://github.com/jeksterslab/dynTools/reference/DeltaTByID.md),
[`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md),
[`DiagnoseScaleByID()`](https://github.com/jeksterslab/dynTools/reference/DiagnoseScaleByID.md),
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
#> $origin
#> [1] "by_id"
#> 
#> $scale
#> [1] "mean_dt"
#> 
#> $requested_scale
#> [1] "mean_dt"
#> 
#> $scale_value
#> [1] 9
#> 
#> $scale_value_supplied
#> [1] FALSE
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
#> $n_nonpositive_dt
#> [1] 0
#> 
#> $average_delta_t_ct_units
#> [1] 1
#> 
#> $median_delta_t_ct_units
#> [1] 1
#> 
#> $interpretation
#> [1] "1 CT time unit = 9 hours."
#> 
#> $time_conversion
#> [1] "time_ct = elapsed time in hours / 9."
#> 
#> $original_time_conversion
#> [1] "Elapsed time in hours = time_ct * 9."
#> 
#> $drift_ct_to_original_multiplier
#> [1] 0.1111111
#> 
#> $drift_original_to_ct_multiplier
#> [1] 9
#> 
#> $diffusion_covariance_ct_to_original_multiplier
#> [1] 0.1111111
#> 
#> $diffusion_covariance_original_to_ct_multiplier
#> [1] 9
#> 
#> $diffusion_sd_ct_to_original_multiplier
#> [1] 0.3333333
#> 
#> $diffusion_sd_original_to_ct_multiplier
#> [1] 3
#> 
#> $drift_conversion
#> [1] "To convert drift estimates from CT-scaled units back to per hours, multiply by 0.111111. Equivalently, divide by 9."
#> 
#> $diffusion_covariance_conversion
#> [1] "To convert diffusion covariance/intensity estimates from CT-scaled units back to per hours, multiply by 0.111111. Equivalently, divide by 9."
#> 
#> $diffusion_sd_conversion
#> [1] "If diffusion is parameterized as a standard deviation or Cholesky factor, convert from CT-scaled units back to per hours by multiplying by 0.333333. Equivalently, divide by sqrt(9)."
#> 
#> $scaling_note
#> [1] "The time scale was chosen so that the average or typical positive consecutive interval is approximately 1 in CT-scaled units. With scale = 'mean_dt', the average positive consecutive interval is approximately 1. With scale = 'median_dt', the median positive consecutive interval is approximately 1."
#> 
```
