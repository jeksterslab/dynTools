# Create Elapsed Time by ID

The function creates an elapsed-time variable within ID. For date-time
variables, elapsed time is computed with
[`difftime()`](https://rdrr.io/r/base/difftime.html). For numeric time
variables, elapsed time is computed by subtraction, optionally
converting from `input_units` to `units`.

## Usage

``` r
ElapsedTimeByID(
  data,
  id,
  time,
  output = "time_elapsed",
  units = "days",
  origin = c("by_id", "global"),
  input_units = NULL,
  replace = FALSE
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

- output:

  Character string. Name of the elapsed-time variable.

- units:

  Character string. Units for the output elapsed time.

- origin:

  Character string. If `origin = "by_id"`, each ID's origin is its own
  minimum non-missing time. If `origin = "global"`, all IDs use the
  global minimum non-missing time.

- input_units:

  Character string or `NULL`. Units of numeric input time. If `NULL`,
  numeric time is assumed to already be in the desired output scale and
  only subtraction is performed.

- replace:

  Logical. If `TRUE`, replace the original `time` variable. If `FALSE`,
  append `output`.

## Value

Returns a data frame.

## See also

Other Dynamic Modeling Utility Functions:
[`CheckDynData()`](https://github.com/jeksterslab/dynTools/reference/CheckDynData.md),
[`DeleteInitialNA()`](https://github.com/jeksterslab/dynTools/reference/DeleteInitialNA.md),
[`DeltaTByID()`](https://github.com/jeksterslab/dynTools/reference/DeltaTByID.md),
[`DetrendByID()`](https://github.com/jeksterslab/dynTools/reference/DetrendByID.md),
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
  id = c(1, 1, 2, 2),
  datetime = as.POSIXct(
    c(
      "2020-01-01 00:00:00",
      "2020-01-02 00:00:00",
      "2020-01-03 12:00:00",
      "2020-01-04 00:00:00"
    ),
    tz = "UTC"
  )
)
ElapsedTimeByID(
  data = data,
  id = "id",
  time = "datetime",
  output = "time",
  units = "days"
)
#>   id            datetime time
#> 1  1 2020-01-01 00:00:00  0.0
#> 2  1 2020-01-02 00:00:00  1.0
#> 3  2 2020-01-03 12:00:00  0.0
#> 4  2 2020-01-04 00:00:00  0.5
```
