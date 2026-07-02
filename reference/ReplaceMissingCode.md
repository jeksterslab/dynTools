# Replace Missing-Value Codes

The function replaces user-specified missing-value codes with `NA` in a
data frame. The replacement is applied column by column and preserves
the original column classes whenever possible.

## Usage

``` r
ReplaceMissingCode(data, values = c(-999, "-999"), columns = names(data))
```

## Arguments

- data:

  Data frame.

- values:

  Vector. Values to replace with `NA`.

- columns:

  Character vector. Names of the columns where replacement should be
  applied. If `NULL`, no columns are modified.

## Value

Returns a data frame.

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
[`GetObservedInitial()`](https://github.com/jeksterslab/dynTools/reference/GetObservedInitial.md),
[`InitialNA()`](https://github.com/jeksterslab/dynTools/reference/InitialNA.md),
[`InsertNA()`](https://github.com/jeksterslab/dynTools/reference/InsertNA.md),
[`LagByID()`](https://github.com/jeksterslab/dynTools/reference/LagByID.md),
[`MakeClockTime()`](https://github.com/jeksterslab/dynTools/reference/MakeClockTime.md),
[`PlotByID()`](https://github.com/jeksterslab/dynTools/reference/PlotByID.md),
[`RegularizeTimeByID()`](https://github.com/jeksterslab/dynTools/reference/RegularizeTimeByID.md),
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
  id = 1:3,
  y = c(1, -999, 3),
  x = c("a", "-999", "c"),
  stringsAsFactors = FALSE
)
data
#>   id    y    x
#> 1  1    1    a
#> 2  2 -999 -999
#> 3  3    3    c

ReplaceMissingCode(
  data = data,
  values = c(-999, "-999")
)
#>   id  y    x
#> 1  1  1    a
#> 2  2 NA <NA>
#> 3  3  3    c
```
