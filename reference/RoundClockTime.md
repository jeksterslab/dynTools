# Round Clock Time

The function rounds, floors, or ceilings clock times to a specified
unit. It supports `POSIXt`, `Date`, and numeric time values.

## Usage

``` r
RoundClockTime(
  x,
  unit = "hour",
  method = c("round", "floor", "ceiling"),
  origin = "1970-01-01",
  tz = "UTC"
)
```

## Arguments

- x:

  A `POSIXt`, `Date`, or numeric vector.

- unit:

  Character string. Unit to round to. Supported values are `"second"`,
  `"minute"`, `"hour"`, `"day"`, and their plural forms.

- method:

  Character string. One of `"round"`, `"floor"`, or `"ceiling"`.

- origin:

  Origin for numeric time values. Only used if `x` is numeric.

- tz:

  Character string. Time zone used when numeric time values are
  converted to `POSIXct`.

## Value

Returns a vector with rounded times.

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
[`ResolveDuplicateIDTime()`](https://github.com/jeksterslab/dynTools/reference/ResolveDuplicateIDTime.md),
[`ScaleByID()`](https://github.com/jeksterslab/dynTools/reference/ScaleByID.md),
[`SubsetByID()`](https://github.com/jeksterslab/dynTools/reference/SubsetByID.md),
[`SummaryByID()`](https://github.com/jeksterslab/dynTools/reference/SummaryByID.md)

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
x <- as.POSIXct(
  "2020-01-01 10:31:00",
  tz = "America/New_York"
)

RoundClockTime(
  x = x,
  unit = "hour"
)
#> [1] "2020-01-01 11:00:00 EST"
```
