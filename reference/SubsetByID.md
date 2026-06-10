# Subset Data Set by ID

The function creates a list of data frames for each ID.

## Usage

``` r
SubsetByID(data, id, time, observed, covariates = NULL)
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

Returns a list by ID numbers.

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
[`ScaleByID()`](https://github.com/jeksterslab/dynTools/reference/ScaleByID.md),
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
    20, 21, 22, 23
  ),
  y2 = c(
    4, 3, 2, 1,
    13, 12, 11, 10,
    23, 22, 21, 20
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
#> 9   3    1 20 23
#> 10  3    2 21 22
#> 11  3    3 22 21
#> 12  3    4 23 20

SubsetByID(
  data = data,
  id = "id",
  time = "time",
  observed = c("y1", "y2")
)
#> $`1`
#>   id time y1 y2
#> 1  1    1  1  4
#> 2  1    2  2  3
#> 3  1    3  3  2
#> 4  1    4  4  1
#> 
#> $`2`
#>   id time y1 y2
#> 1  2    1 10 13
#> 2  2    2 11 12
#> 3  2    3 12 11
#> 4  2    4 13 10
#> 
#> $`3`
#>   id time y1 y2
#> 1  3    1 20 23
#> 2  3    2 21 22
#> 3  3    3 22 21
#> 4  3    4 23 20
#> 
```
