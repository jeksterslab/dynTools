# Drop IDs From a Data Frame

The function removes rows belonging to one or more IDs. It is a small
convenience wrapper used after ID-level diagnostics identify IDs for
exclusion or sensitivity analysis.

## Usage

``` r
DropByID(data, id, drop = NULL)
```

## Arguments

- data:

  Data frame.

- id:

  Character string. Name of the ID variable.

- drop:

  Vector. ID values to remove. If `NULL` or empty, `data` is returned
  unchanged.

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
[`DiagnoseScaleByID()`](https://github.com/jeksterslab/dynTools/reference/DiagnoseScaleByID.md),
[`DiagnosticsByID()`](https://github.com/jeksterslab/dynTools/reference/DiagnosticsByID.md),
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
  id = c(1, 1, 2, 2, 3, 3),
  y = 1:6
)

DropByID(
  data = data,
  id = "id",
  drop = c(2, 3)
)
#>   id y
#> 1  1 1
#> 2  1 2
```
