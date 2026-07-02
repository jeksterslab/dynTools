# Regularize Time By ID

The function computes the smallest positive time difference across IDs
and uses that global delta time to regularize the time grid within each
ID. For each ID, a complete sequence from the first to the last observed
time is created using the global smallest delta time. Rows not present
in the original data are inserted with missing values for all non-ID and
non-time variables.

## Usage

``` r
RegularizeTimeSmallestDeltaTByID(
  data,
  id,
  time,
  tol = sqrt(.Machine$double.eps)
)
```

## Arguments

- data:

  Data frame.

- id:

  Character string. ID variable.

- time:

  Character string. Time variable.

- tol:

  Numeric. Tolerance used to check whether observed times align with the
  regularized time grid.

## Value

Returns a data frame. The global smallest delta time is stored as the
`delta_t` attribute.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
data <- data.frame(
  id = c(1, 1, 1, 2, 2, 2),
  time = c(0, 2, 4, 0, 1, 2),
  y = c(1, 2, 3, 10, 11, 12)
)
RegularizeTimeSmallestDeltaTByID(
  data = data,
  id = "id",
  time = "time"
)
#>   id time  y
#> 1  1    0  1
#> 2  1    1 NA
#> 3  1    2  2
#> 4  1    3 NA
#> 5  1    4  3
#> 6  2    0 10
#> 7  2    1 11
#> 8  2    2 12
```
