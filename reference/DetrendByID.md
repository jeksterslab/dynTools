# Detrend Observed Variables by ID

The function removes polynomial time trends from observed variables
within each ID. Missing observed values are ignored when estimating the
trend and remain missing in the detrended variables.

## Usage

``` r
DetrendByID(
  data,
  id,
  time,
  observed,
  covariates = NULL,
  degree = 1L,
  replace = FALSE,
  keep_mean = TRUE,
  prefix = "detrend"
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

- degree:

  Non-negative integer. Degree of the polynomial trend. Use `degree = 0`
  for mean centering by ID when `keep_mean = FALSE`. If `degree = 0` and
  `keep_mean = TRUE`, the original observed values are returned.

- replace:

  Logical. If `TRUE`, replace observed variables with detrended
  variables. If `FALSE`, append detrended variables to the data frame.

- keep_mean:

  Logical. If `TRUE`, preserve the original within-ID mean after
  detrending. If `FALSE`, return ordinary residuals from the within-ID
  trend model.

- prefix:

  Character string. Prefix for detrended variables when
  `replace = FALSE`.

## Value

Returns a data frame.

## Details

If `keep_mean = TRUE`, the within-ID observed mean is added back after
removing the fitted time trend. This removes temporal drift while
preserving each ID's observed-variable level. If `keep_mean = FALSE`,
the output is the ordinary residual from the within-ID polynomial trend
model.

## See also

Other Dynamic Modeling Utility Functions:
[`CheckDynData()`](https://github.com/jeksterslab/dynTools/reference/CheckDynData.md),
[`DeleteInitialNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteInitialNA.md),
[`DeltaTByID()`](https://github.com/jeksterslab/dynTools/reference/DeltaTByID.md),
[`ElapsedTimeByID()`](https://github.com/jeksterslab/dynTools/reference/ElapsedTimeByID.md),
[`FilterByID()`](https://github.com/jeksterslab/dynTools/reference/FilterByID.md),
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
[`SubsetByID()`](https://github.com/jeksterslab/dynTools/reference/SubsetByID.md),
[`SummaryByID()`](https://github.com/jeksterslab/dynTools/reference/SummaryByID.md)

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
data <- data.frame(
  id = rep(1:2, each = 4),
  time = rep(1:4, times = 2),
  y = rep(1:4, times = 2)
)
data
#>   id time y
#> 1  1    1 1
#> 2  1    2 2
#> 3  1    3 3
#> 4  1    4 4
#> 5  2    1 1
#> 6  2    2 2
#> 7  2    3 3
#> 8  2    4 4

DetrendByID(
  data = data,
  id = "id",
  time = "time",
  observed = "y",
  degree = 1,
  keep_mean = TRUE
)
#>   id time y detrend_y
#> 1  1    1 1       2.5
#> 2  1    2 2       2.5
#> 3  1    3 3       2.5
#> 4  1    4 4       2.5
#> 5  2    1 1       2.5
#> 6  2    2 2       2.5
#> 7  2    3 3       2.5
#> 8  2    4 4       2.5

DetrendByID(
  data = data,
  id = "id",
  time = "time",
  observed = "y",
  degree = 1,
  keep_mean = FALSE
)
#>   id time y     detrend_y
#> 1  1    1 1 -2.537558e-17
#> 2  1    2 2  4.229263e-17
#> 3  1    3 3 -8.458526e-18
#> 4  1    4 4 -8.458526e-18
#> 5  2    1 1 -2.537558e-17
#> 6  2    2 2  4.229263e-17
#> 7  2    3 3 -8.458526e-18
#> 8  2    4 4 -8.458526e-18
```
