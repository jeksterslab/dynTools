# Check Dynamic Modeling Data

The function checks whether a data frame has the variables and structure
required by the dynamic modeling utility functions.

## Usage

``` r
CheckDynData(
  data,
  id,
  time,
  observed,
  covariates = NULL,
  require_unique = TRUE,
  require_numeric_time = TRUE,
  require_numeric_observed = TRUE,
  require_numeric_covariates = FALSE,
  min_rows = 2L
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

- require_unique:

  Logical. If `TRUE`, require unique `id`-`time` combinations.

- require_numeric_time:

  Logical. If `TRUE`, require the time variable to be numeric.

- require_numeric_observed:

  Logical. If `TRUE`, require observed variables to be numeric.

- require_numeric_covariates:

  Logical. If `TRUE`, require covariates to be numeric.

- min_rows:

  Positive integer. Minimum number of rows required per ID.

## Value

Returns `TRUE` invisibly if all checks pass.

## See also

Other Dynamic Modeling Utility Functions:
[`DeleteInitialNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteInitialNA.md),
[`DeltaTByID()`](https://github.com/jeksterslab/dynTools/reference/DeltaTByID.md),
[`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md),
[`ElapsedTimeByID()`](https://github.com/jeksterslab/dynTools/reference/ElapsedTimeByID.md),
[`FilterByID()`](https://github.com/jeksterslab/dynTools/reference/FilterByID.md),
[`InitialNA()`](https://github.com/jeksterslab/dynTools/reference/InitialNA.md),
[`InsertNA()`](https://github.com/jeksterslab/dynTools/reference/InsertNA.md),
[`LagByID()`](https://github.com/jeksterslab/dynTools/reference/LagByID.md),
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
CheckDynData(
  data = data,
  id = "id",
  time = "time",
  observed = c("y1", "y2")
)
```
