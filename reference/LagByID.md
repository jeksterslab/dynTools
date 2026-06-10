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
  time = rep(1:3, times = 2),
  y1 = rnorm(6),
  y2 = rnorm(6)
)
data
#>   id time         y1          y2
#> 1  1    1  0.5429963  1.88850493
#> 2  1    2 -0.9140748 -0.09744510
#> 3  1    3  0.4681544 -0.93584735
#> 4  2    1  0.3629513 -0.01595031
#> 5  2    2 -1.3045435 -0.82678895
#> 6  2    3  0.7377763 -1.51239965

LagByID(
  data = data,
  id = "id",
  time = "time",
  observed = c("y1", "y2"),
  lags = 1
)
#>   id time         y1          y2    lag1_y1     lag1_y2
#> 1  1    1  0.5429963  1.88850493         NA          NA
#> 2  1    2 -0.9140748 -0.09744510  0.5429963  1.88850493
#> 3  1    3  0.4681544 -0.93584735 -0.9140748 -0.09744510
#> 4  2    1  0.3629513 -0.01595031         NA          NA
#> 5  2    2 -1.3045435 -0.82678895  0.3629513 -0.01595031
#> 6  2    3  0.7377763 -1.51239965 -1.3045435 -0.82678895
```
