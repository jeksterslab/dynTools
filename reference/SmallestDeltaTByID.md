# Smallest Global Delta Time By ID

The function computes the smallest positive time difference between
consecutive unique time points within ID, then takes the minimum across
IDs.

## Usage

``` r
SmallestDeltaTByID(data, id, time)
```

## Arguments

- data:

  Data frame.

- id:

  Character string. ID variable.

- time:

  Character string. Time variable.

## Value

Returns a numeric value.

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
data <- data.frame(
  id = c(1, 1, 1, 2, 2, 2),
  time = c(0, 2, 4, 0, 1, 2),
  y = c(1, 2, 3, 10, 11, 12)
)
SmallestDeltaTByID(
  data = data,
  id = "id",
  time = "time"
)
#> [1] 1
```
