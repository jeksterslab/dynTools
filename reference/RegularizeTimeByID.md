# Regularize Time by ID

The function inserts rows with missing values so that time follows a
regular grid. A global grid uses the same time sequence for every ID. An
ID-specific grid uses each ID's own minimum and maximum observed time
values. If `method = "preserve"`, the function completes the regular
grid while retaining empirical off-grid time values. If
`method = "snap"`, empirical time values are snapped to the nearest grid
point and the returned data use only grid time values.

## Usage

``` r
RegularizeTimeByID(
  data,
  id,
  time,
  observed,
  covariates = NULL,
  delta_t,
  grid = c("global", "by_id"),
  method = c("preserve", "snap")
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

- delta_t:

  Positive number. Time interval.

- grid:

  Character string. If `grid = "global"`, use one time grid from the
  global minimum to the global maximum time value. If `grid = "by_id"`,
  use an ID-specific time grid from each ID's minimum to maximum time
  value.

- method:

  Character string. If `method = "preserve"`, complete the regular grid
  but preserve observed off-grid time values. If `method = "snap"`, snap
  observed time values to the nearest grid point so the output contains
  only regular grid times. When multiple rows for the same ID snap to
  the same grid point, the row closest to the grid point is kept; ties
  are broken by the largest number of non-missing observed/covariate
  values and then by original order.

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
  id = c(1, 1, 2, 2),
  time = c(1, 3, 1, 2),
  y = c(10, 12, 20, 21)
)
data
#>   id time  y
#> 1  1    1 10
#> 2  1    3 12
#> 3  2    1 20
#> 4  2    2 21

RegularizeTimeByID(
  data = data,
  id = "id",
  time = "time",
  observed = "y",
  delta_t = 1,
  grid = "by_id"
)
#>   id time  y
#> 1  1    1 10
#> 2  1    2 NA
#> 3  1    3 12
#> 4  2    1 20
#> 5  2    2 21

RegularizeTimeByID(
  data = data.frame(
    id = c(1, 1),
    time = c(1.0, 1.7),
    y = c(10, 17)
  ),
  id = "id",
  time = "time",
  observed = "y",
  delta_t = 0.5,
  grid = "by_id",
  method = "snap"
)
#>   id time  y
#> 1  1  1.0 10
#> 2  1  1.5 17
```
