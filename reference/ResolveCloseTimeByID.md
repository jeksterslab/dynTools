# Resolve Close Time Points by ID

The function resolves observations that occur very close together within
ID. Within each ID, rows are ordered by time and grouped into close-time
clusters. Consecutive observations belong to the same cluster when the
time gap between them is less than `min_gap`. One row is retained from
each close-time cluster.

## Usage

``` r
ResolveCloseTimeByID(
  data,
  id,
  time,
  observed,
  min_gap,
  method = c("max_complete", "first", "last")
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

- min_gap:

  Numeric scalar or `difftime`. Minimum allowed gap between consecutive
  observations within ID. For numeric `time`, `min_gap` must be a
  positive finite numeric scalar in the same units as `time`. For `Date`
  or `POSIXt` `time`, `min_gap` must be a positive `difftime` object.

- method:

  Character string. Method used to select the row retained from each
  close-time cluster. If `method = "max_complete"`, the row with the
  largest number of non-missing observed variables is retained. Ties are
  resolved by retaining the earliest row in the sorted data. If
  `method = "first"`, the first row in the cluster is retained. If
  `method = "last"`, the last row in the cluster is retained.

## Value

Returns a data frame with close-time observations resolved within ID.

## Details

This is useful before fitting continuous-time models, where observations
that are nearly simultaneous can create numerical problems, especially
when the observed values change substantially over a very small time
interval.

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
[`ReplaceMissingCode()`](https://github.com/jeksterslab/dynTools/reference/ReplaceMissingCode.md),
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
  id = c(1, 1, 1, 1, 2, 2),
  datetime = as.POSIXct(
    c(
      "2020-01-01 00:00:00",
      "2020-01-01 00:02:00",
      "2020-01-01 01:00:00",
      "2020-01-01 01:03:00",
      "2020-01-01 00:00:00",
      "2020-01-01 00:10:00"
    ),
    tz = "UTC"
  ),
  y1 = c(1, NA, 3, 4, 5, 6),
  y2 = c(NA, 2, 3, 4, 5, 6)
)

ResolveCloseTimeByID(
  data = data,
  id = "id",
  time = "datetime",
  observed = c("y1", "y2"),
  min_gap = as.difftime(
    5,
    units = "mins"
  ),
  method = "max_complete"
)
#>   id            datetime y1 y2
#> 1  1 2020-01-01 00:00:00  1 NA
#> 2  1 2020-01-01 01:00:00  3  3
#> 3  2 2020-01-01 00:00:00  5  5
#> 4  2 2020-01-01 00:10:00  6  6
```
