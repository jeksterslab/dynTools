# Create Lagged Variables by ID

The function creates lagged observed variables within ID. Lagged values
never cross ID boundaries.

## Usage

``` r
LagByID(data, id, time, observed, covariates = NULL, lags = 1L, prefix = "lag")
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

- lags:

  Positive integer vector. Lags to create.

- prefix:

  Character string. Prefix for the lagged variable names.

## Value

Returns a data frame.

## See also

Other Dynamic Modeling Utility Functions:
[`CheckDynData()`](https://github.com/jeksterslab/dynTools/reference/CheckDynData.md),
[`DeleteInitialNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteInitialNA.md),
[`DeltaTByID()`](https://github.com/jeksterslab/dynTools/reference/DeltaTByID.md),
[`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md),
[`ElapsedTimeByID()`](https://github.com/jeksterslab/dynTools/reference/ElapsedTimeByID.md),
[`FilterByID()`](https://github.com/jeksterslab/dynTools/reference/FilterByID.md),
[`InitialNA()`](https://github.com/jeksterslab/dynTools/reference/InitialNA.md),
[`InsertNA()`](https://github.com/jeksterslab/dynTools/reference/InsertNA.md),
[`MakeClockTime()`](https://github.com/jeksterslab/dynTools/reference/MakeClockTime.md),
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
  time = rep(1:3, times = 2),
  y1 = rnorm(6),
  y2 = rnorm(6)
)
LagByID(
  data = data,
  id = "id",
  time = "time",
  observed = c("y1", "y2"),
  lags = 1
)
#>   id time          y1         y2    lag1_y1    lag1_y2
#> 1  1    1  0.33584812  0.6235182         NA         NA
#> 2  1    2  1.03850610 -0.9535234  0.3358481  0.6235182
#> 3  1    3  0.92072857 -0.5428288  1.0385061 -0.9535234
#> 4  2    1  0.72087816  0.5809965         NA         NA
#> 5  2    2 -1.04311894  0.7681787  0.7208782  0.5809965
#> 6  2    3 -0.09018639  0.4637676 -1.0431189  0.7681787
```
