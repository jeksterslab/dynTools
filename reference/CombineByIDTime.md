# Combine Data Sets by ID and Time

The function appends observed variables from one data set to another
data set using exact `id`-`time` matches. Rows in `data` define the
output `id`-`time` structure. If an `id`-`time` row in `data` is not
present in `append_data`, missing values are inserted for the appended
observed variables.

## Usage

``` r
CombineByIDTime(data, append_data, id, time, observed, covariates = NULL)
```

## Arguments

- data:

  Data frame. A data frame object of data for potentially multiple
  subjects that contain a column of subject ID numbers (i.e., an ID
  variable), a column indicating subject-specific measurement occasions
  (i.e., a TIME variable), at least one column of observed values.

- append_data:

  Data frame. A data frame object containing the `id` and `time` columns
  and the observed variables to append to `data`.

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

Returns a data frame.

## See also

Other Dynamic Modeling Utility Functions:
[`CheckDynData()`](https://github.com/jeksterslab/dynTools/reference/CheckDynData.md),
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
[`GetObservedInitial()`](https://github.com/jeksterslab/dynTools/reference/GetObservedInitial.md),
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
  id = c(1, 1, 1, 2, 2, 2),
  time = c(1, 2, 3, 1, 2, 3),
  cov = c(10, 10, 10, 20, 20, 20)
)

append_data <- data.frame(
  id = c(1, 1, 2),
  time = c(1, 3, 2),
  y1 = c(11, 13, 22),
  y2 = c(101, 103, 202)
)

CombineByIDTime(
  data = data,
  append_data = append_data,
  id = "id",
  time = "time",
  observed = c("y1", "y2"),
  covariates = "cov"
)
#>   id time cov y1  y2
#> 1  1    1  10 11 101
#> 2  1    2  10 NA  NA
#> 3  1    3  10 13 103
#> 4  2    1  20 NA  NA
#> 5  2    2  20 22 202
#> 6  2    3  20 NA  NA
```
