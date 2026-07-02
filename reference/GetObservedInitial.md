# Get Observed Initial Means and Covariances

The function extracts the first observed time point for each ID and
computes the sample mean vector and sample covariance matrix of the
observed variables across IDs. The resulting mean vector and covariance
matrix can be used as fixed initial conditions in dynamic models.

## Usage

``` r
GetObservedInitial(data, id, time, observed, ridge = 1e-06)
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

- ridge:

  Positive numeric. Small value added to the diagonal of the covariance
  matrix if the estimated covariance matrix is not positive definite.

## Value

Returns a list with the following elements:

- `data`:

  Data frame containing the first observed time point for each ID and
  the selected observed variables.

- `mean`:

  Numeric vector of observed-variable means computed from the first
  observed time point across IDs.

- `cov`:

  Observed-variable covariance matrix computed from complete cases of
  the first observed time point across IDs.

- `n`:

  Number of IDs with a first observed row.

- `n_complete`:

  Number of IDs with complete data on all selected observed variables at
  the first observed time point.

## Details

Rows are sorted by ID and time before selecting the first row for each
ID. Missing observed values are ignored when computing the mean vector.
The covariance matrix is computed using complete cases of the selected
first-time observations.

If the covariance matrix is not positive definite, a small ridge value
is added to the diagonal.

## See also

Other Dynamic Modeling Utility Functions:
[`CheckDynData()`](https://github.com/jeksterslab/dynTools/reference/CheckDynData.md),
[`CombineByIDTime()`](https://github.com/jeksterslab/dynTools/reference/CombineByIDTime.md),
[`DeleteInitialNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteInitialNA.md),
[`DeleteObservedAllNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteObservedAllNA.md),
[`DeltaTByID()`](https://github.com/jeksterslab/dynTools/reference/DeltaTByID.md),
[`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md),
[`DiagnoseDetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DiagnoseDetrendByID.md),
[`DiagnosticsByID()`](https://github.com/jeksterslab/dynTools/reference/DiagnosticsByID.md),
[`DropByID()`](https://github.com/jeksterslab/dynTools/reference/DropByID.md),
[`ElapsedTimeByID()`](https://github.com/jeksterslab/dynTools/reference/ElapsedTimeByID.md),
[`ElapsedTimeByIDCT()`](https://github.com/jeksterslab/dynTools/reference/ElapsedTimeByIDCT.md),
[`FilterByID()`](https://github.com/jeksterslab/dynTools/reference/FilterByID.md),
[`FilterObservedRows()`](https://github.com/jeksterslab/dynTools/reference/FilterObservedRows.md),
[`FlagDiagnosticsByID()`](https://github.com/jeksterslab/dynTools/reference/FlagDiagnosticsByID.md),
[`GetDropID()`](https://github.com/jeksterslab/dynTools/reference/GetDropID.md),
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
  id = rep(1:3, each = 4),
  time = rep(1:4, times = 3),
  y1 = c(1, 2, 3, 4, 2, 3, 4, 5, 3, 4, 5, 6),
  y2 = c(4, 3, 2, 1, 5, 4, 3, 2, 6, 5, 4, 3)
)
data
#>    id time y1 y2
#> 1   1    1  1  4
#> 2   1    2  2  3
#> 3   1    3  3  2
#> 4   1    4  4  1
#> 5   2    1  2  5
#> 6   2    2  3  4
#> 7   2    3  4  3
#> 8   2    4  5  2
#> 9   3    1  3  6
#> 10  3    2  4  5
#> 11  3    3  5  4
#> 12  3    4  6  3

init <- GetObservedInitial(
  data = data,
  id = "id",
  time = "time",
  observed = c("y1", "y2")
)

init$data
#>   y1 y2
#> 1  1  4
#> 2  2  5
#> 3  3  6
init$mean
#> y1 y2 
#>  2  5 
init$cov
#>          y1       y2
#> y1 1.000001 1.000000
#> y2 1.000000 1.000001
init$n
#> [1] 3
init$n_complete
#> [1] 3
```
