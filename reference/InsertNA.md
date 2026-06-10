# Insert NAs for Missing Observations

The function creates a sequence of time values. It starts with the
smallest time value as the starting point and the largest time value as
the endpoint. The sequence is incremented by `delta_t`. This new
sequence is combined with the existing empirical time values. For any
specific time value where there are no observations, NAs are inserted.

## Usage

``` r
InsertNA(data, id, time, observed, covariates = NULL, delta_t)
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

- delta_t:

  Positive number. Time interval.

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
  id = c(1, 1, 1, 2, 2, 2),
  time = c(1, 2, 4, 1, 3, 4),
  y1 = c(10, 11, 13, 20, 22, 23),
  y2 = c(5, 6, 8, 15, 17, 18)
)
data
#>   id time y1 y2
#> 1  1    1 10  5
#> 2  1    2 11  6
#> 3  1    4 13  8
#> 4  2    1 20 15
#> 5  2    3 22 17
#> 6  2    4 23 18

InsertNA(
  data = data,
  id = "id",
  time = "time",
  observed = c("y1", "y2"),
  delta_t = 1
)
#>   id time y1 y2
#> 1  1    1 10  5
#> 2  1    2 11  6
#> 3  1    3 NA NA
#> 4  1    4 13  8
#> 5  2    1 20 15
#> 6  2    2 NA NA
#> 7  2    3 22 17
#> 8  2    4 23 18
```
