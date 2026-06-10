# Scale by ID

The function scales the data by ID.

## Usage

``` r
ScaleByID(
  data,
  id,
  time,
  observed,
  covariates = NULL,
  scale = TRUE,
  obs_skip = NULL,
  cov_skip = NULL
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

- scale:

  Logical. If `scale = TRUE`, standardize by `id`. If `scale = FALSE`,
  mean center by `id`.

- obs_skip:

  Character vector. A vector of character strings of the names of the
  observed variables to skip centering/scaling.

- cov_skip:

  Character vector. A vector of character strings of the names of the
  covariates to skip centering/scaling.

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
[`LagByID()`](https://github.com/jeksterslab/dynTools/reference/LagByID.md),
[`MakeClockTime()`](https://github.com/jeksterslab/dynTools/reference/MakeClockTime.md),
[`PlotByID()`](https://github.com/jeksterslab/dynTools/reference/PlotByID.md),
[`RegularizeTimeByID()`](https://github.com/jeksterslab/dynTools/reference/RegularizeTimeByID.md),
[`ReplaceMissingCode()`](https://github.com/jeksterslab/dynTools/reference/ReplaceMissingCode.md),
[`ResolveDuplicateIDTime()`](https://github.com/jeksterslab/dynTools/reference/ResolveDuplicateIDTime.md),
[`RoundClockTime()`](https://github.com/jeksterslab/dynTools/reference/RoundClockTime.md),
[`SubsetByID()`](https://github.com/jeksterslab/dynTools/reference/SubsetByID.md),
[`SummaryByID()`](https://github.com/jeksterslab/dynTools/reference/SummaryByID.md)

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
data <- data.frame(
  id = rep(1:3, each = 4),
  time = rep(1:4, times = 3),
  y1 = c(
    1, 2, 3, 4,
    10, 11, 12, 13,
    20, 22, 24, 26
  ),
  y2 = c(
    4, 3, 2, 1,
    13, 12, 11, 10,
    26, 24, 22, 20
  )
)
data
#>    id time y1 y2
#> 1   1    1  1  4
#> 2   1    2  2  3
#> 3   1    3  3  2
#> 4   1    4  4  1
#> 5   2    1 10 13
#> 6   2    2 11 12
#> 7   2    3 12 11
#> 8   2    4 13 10
#> 9   3    1 20 26
#> 10  3    2 22 24
#> 11  3    3 24 22
#> 12  3    4 26 20

ScaleByID(
  data = data,
  id = "id",
  time = "time",
  observed = c("y1", "y2")
)
#>    id time         y1         y2
#> 1   1    1 -1.1618950  1.1618950
#> 2   1    2 -0.3872983  0.3872983
#> 3   1    3  0.3872983 -0.3872983
#> 4   1    4  1.1618950 -1.1618950
#> 5   2    1 -1.1618950  1.1618950
#> 6   2    2 -0.3872983  0.3872983
#> 7   2    3  0.3872983 -0.3872983
#> 8   2    4  1.1618950 -1.1618950
#> 9   3    1 -1.1618950  1.1618950
#> 10  3    2 -0.3872983  0.3872983
#> 11  3    3  0.3872983 -0.3872983
#> 12  3    4  1.1618950 -1.1618950

ScaleByID(
  data = data,
  id = "id",
  time = "time",
  observed = c("y1", "y2"),
  scale = FALSE
)
#>    id time   y1   y2
#> 1   1    1 -1.5  1.5
#> 2   1    2 -0.5  0.5
#> 3   1    3  0.5 -0.5
#> 4   1    4  1.5 -1.5
#> 5   2    1 -1.5  1.5
#> 6   2    2 -0.5  0.5
#> 7   2    3  0.5 -0.5
#> 8   2    4  1.5 -1.5
#> 9   3    1 -3.0  3.0
#> 10  3    2 -1.0  1.0
#> 11  3    3  1.0 -1.0
#> 12  3    4  3.0 -3.0
```
