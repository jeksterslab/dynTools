# Make Clock Time

The function combines a date and a clock time into a `POSIXct` vector.
Clock time can be supplied as decimal hours, for example `13.5`, or as a
character time, for example `"13:30"` or `"13:30:00"`.

## Usage

``` r
MakeClockTime(
  date,
  time,
  tz = "UTC",
  date_formats = c("%m/%d/%y", "%m/%d/%Y", "%Y-%m-%d"),
  invalid = c("NA", "error")
)
```

## Arguments

- date:

  Date vector. Dates can be supplied as `Date`, `POSIXt`, or character
  values.

- time:

  Numeric or character vector. Clock time in decimal hours, `"HH:MM"`,
  or `"HH:MM:SS"` format.

- tz:

  Character string. Time zone passed to
  [`as.POSIXct()`](https://rdrr.io/r/base/as.POSIXlt.html).

- date_formats:

  Character vector. Date formats used to parse character dates.

- invalid:

  Character string. If `invalid = "NA"`, invalid clock times are
  returned as `NA`. If `invalid = "error"`, invalid clock times throw an
  error.

## Value

Returns a `POSIXct` vector.

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
MakeClockTime(
  date = "2020-01-02",
  time = 13.5,
  tz = "America/New_York"
)
#> [1] "2020-01-02 13:30:00 EST"

MakeClockTime(
  date = "01/02/20",
  time = "13:30",
  tz = "America/New_York"
)
#> [1] "2020-01-02 13:30:00 EST"
```
