# Filter Dynamic Modeling Data by ID

The function removes IDs that do not satisfy minimum data requirements.

## Usage

``` r
FilterByID(
  data,
  id,
  time,
  observed,
  covariates = NULL,
  min_rows = 2L,
  min_complete = 2L,
  max_prop_missing = 1,
  allow_initial_na = TRUE,
  allow_all_missing = FALSE
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

- min_rows:

  Non-negative integer. Minimum number of rows required per ID.

- min_complete:

  Non-negative integer. Minimum number of complete observed rows
  required per ID.

- max_prop_missing:

  Numeric. Maximum allowed proportion of missing values across observed
  variables.

- allow_initial_na:

  Logical. If `FALSE`, remove IDs where the initial row contains missing
  values.

- allow_all_missing:

  Logical. If `FALSE`, remove IDs where all observed values are missing.

## Value

Returns a data frame.

## See also

Other Dynamic Modeling Utility Functions:
[`CheckDynData()`](https://github.com/jeksterslab/dynTools/reference/CheckDynData.md),
[`DeleteInitialNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteInitialNA.md),
[`DeltaTByID()`](https://github.com/jeksterslab/dynTools/reference/DeltaTByID.md),
[`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md),
[`ElapsedTimeByID()`](https://github.com/jeksterslab/dynTools/reference/ElapsedTimeByID.md),
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
[`SubsetByID()`](https://github.com/jeksterslab/dynTools/reference/SubsetByID.md),
[`SummaryByID()`](https://github.com/jeksterslab/dynTools/reference/SummaryByID.md)

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
data <- data.frame(
  id = rep(1:3, each = 3),
  time = rep(1:3, times = 3),
  y = c(1, 2, 3, NA, NA, 4, NA, NA, NA)
)
data
#>   id time  y
#> 1  1    1  1
#> 2  1    2  2
#> 3  1    3  3
#> 4  2    1 NA
#> 5  2    2 NA
#> 6  2    3  4
#> 7  3    1 NA
#> 8  3    2 NA
#> 9  3    3 NA

FilterByID(
  data = data,
  id = "id",
  time = "time",
  observed = "y",
  min_complete = 2
)
#>   id time y
#> 1  1    1 1
#> 2  1    2 2
#> 3  1    3 3
```
