# Check for NAs in Initial Row By ID

The function checks if there are missing values for the initial row by
ID.

## Usage

``` r
InitialNA(data, id, time, observed, covariates = NULL)
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

## Value

Returns a vector of ID numbers where the initial row has any missing
value.

## See also

Other Dynamic Modeling Utility Functions:
[`CheckDynData()`](https://github.com/jeksterslab/dynTools/reference/CheckDynData.md),
[`DeleteInitialNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteInitialNA.md),
[`DeltaTByID()`](https://github.com/jeksterslab/dynTools/reference/DeltaTByID.md),
[`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md),
[`ElapsedTimeByID()`](https://github.com/jeksterslab/dynTools/reference/ElapsedTimeByID.md),
[`FilterByID()`](https://github.com/jeksterslab/dynTools/reference/FilterByID.md),
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
  id = rep(1:2, each = 5),
  time = rep(1:5, times = 2),
  y1 = c(NA, NA, 3, 4, 5, 10, 11, 12, 13, 14),
  y2 = c(NA, 2, 3, 4, 5, 10, 11, 12, 13, 14),
  y3 = c(1, NA, 3, 4, 5, 10, 11, 12, 13, 14)
)
data
#>    id time y1 y2 y3
#> 1   1    1 NA NA  1
#> 2   1    2 NA  2 NA
#> 3   1    3  3  3  3
#> 4   1    4  4  4  4
#> 5   1    5  5  5  5
#> 6   2    1 10 10 10
#> 7   2    2 11 11 11
#> 8   2    3 12 12 12
#> 9   2    4 13 13 13
#> 10  2    5 14 14 14

InitialNA(
  data = data,
  id = "id",
  time = "time",
  observed = paste0("y", 1:3)
)
#> [1] 1
```
