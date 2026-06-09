# Resolve Duplicate ID-Time Rows

The function resolves exact duplicate `id`-`time` rows using a simple
deterministic rule. This is useful before inserting missing rows on a
time grid because grid-completion functions generally require unique
`id`-`time` combinations.

## Usage

``` r
ResolveDuplicateIDTime(
  data,
  id,
  time,
  observed = NULL,
  covariates = NULL,
  method = c("first", "last", "max_complete"),
  order_by = NULL,
  decreasing = FALSE
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

- method:

  Character string. Rule used to choose one row from each duplicated
  `id`-`time` group. If `method = "first"`, keep the first row after
  sorting by `id` and `time`. If `method = "last"`, keep the last row
  after sorting by `id` and `time`. If `method = "max_complete"`, keep
  the row with the largest number of non-missing values in `observed`.

- order_by:

  Character vector. Optional columns used to break ties after the main
  `method` rule.

- decreasing:

  Logical. If `TRUE`, sort `order_by` columns in decreasing order.

## Value

Returns a data frame with unique `id`-`time` rows.

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
[`RegularizeTimeByID()`](https://github.com/jeksterslab/dynTools/reference/RegularizeTimeByID.md),
[`ReplaceMissingCode()`](https://github.com/jeksterslab/dynTools/reference/ReplaceMissingCode.md),
[`RoundClockTime()`](https://github.com/jeksterslab/dynTools/reference/RoundClockTime.md),
[`ScaleByID()`](https://github.com/jeksterslab/dynTools/reference/ScaleByID.md),
[`SubsetByID()`](https://github.com/jeksterslab/dynTools/reference/SubsetByID.md),
[`SummaryByID()`](https://github.com/jeksterslab/dynTools/reference/SummaryByID.md)

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
data <- data.frame(
  id = c(1, 1, 1),
  time = c(0, 0, 1),
  y1 = c(NA, 1, 2),
  y2 = c(NA, 1, 3)
)
ResolveDuplicateIDTime(
  data = data,
  id = "id",
  time = "time",
  observed = c("y1", "y2"),
  method = "max_complete"
)
#>   id time y1 y2
#> 1  1    0  1  1
#> 2  1    1  2  3
```
