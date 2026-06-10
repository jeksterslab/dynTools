# Summarize Time Intervals by ID

The function returns a diagnostic table describing the spacing of the
time variable within each ID.

## Usage

``` r
DeltaTByID(
  data,
  id,
  time,
  observed = NULL,
  covariates = NULL,
  tolerance = sqrt(.Machine$double.eps)
)
```

## Arguments

- data:

  Data frame. A data frame object.

- id:

  Character string. A character string of the name of the ID variable in
  the data.

- time:

  Character string. A character string of the name of the TIME variable
  in the data.

- observed:

  Character vector. Optional vector of character strings of the names of
  the observed variables in the data.

- covariates:

  Character vector. Optional vector of character strings of the names of
  the covariates in the data.

- tolerance:

  Numeric. Tolerance used to determine whether the time intervals are
  regular.

## Value

Returns a data frame with one row per ID.

## See also

Other Dynamic Modeling Utility Functions:
[`CheckDynData()`](https://github.com/jeksterslab/dynTools/reference/CheckDynData.md),
[`DeleteInitialNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteInitialNA.md),
[`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md),
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
  id = rep(1:2, each = 3),
  time = c(1, 2, 3, 1, 3, 4),
  y = rnorm(6)
)
data
#>   id time           y
#> 1  1    1  2.06502490
#> 2  1    2 -1.63098940
#> 3  1    3  0.51242695
#> 4  2    1 -1.86301149
#> 5  2    3 -0.52201251
#> 6  2    4 -0.05260191

DeltaTByID(
  data = data,
  id = "id",
  time = "time",
  observed = "y"
)
#>   id n_rows n_intervals time_min time_max min_delta_t median_delta_t
#> 1  1      3           2        1        3           1            1.0
#> 2  2      3           2        1        4           1            1.5
#>   max_delta_t n_unique_delta_t regular
#> 1           1                1    TRUE
#> 2           2                2   FALSE
```
