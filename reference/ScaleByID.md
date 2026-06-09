# Scale by ID

The function scales the data by ID.

## Usage

``` r
ScaleByID(
  data,
  id,
  time,
  observed,
  covariates = NULL,
  scale = TRUE,
  obs_skip = NULL,
  cov_skip = NULL,
  ncores = NULL
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

- scale:

  Logical. If `scale = TRUE`, standardize by `id`. If `scale = FALSE`,
  mean center by `id`.

- obs_skip:

  Character vector. A vector of character strings of the names of the
  observed variables to skip centering/scaling.

- cov_skip:

  Character vector. A vector of character strings of the names of the
  covariates to skip centering/scaling.

- ncores:

  Positive integer. Number of cores to use. If `ncores = NULL`, use a
  single core. Consider using multiple cores when number of individuals
  is large.

## Value

Returns a data frame.

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
[`RoundClockTime()`](https://github.com/jeksterslab/dynTools/reference/RoundClockTime.md),
[`SubsetByID()`](https://github.com/jeksterslab/dynTools/reference/SubsetByID.md),
[`SummaryByID()`](https://github.com/jeksterslab/dynTools/reference/SummaryByID.md)

## Author

Ivan Jacob Agaloos Pesigan

## Examples

``` r
if (requireNamespace("simStateSpace", quietly = TRUE)) {
  # prepare parameters
  set.seed(42)
  ## number of individuals
  n <- 5
  ## time points
  time <- 5
  ## dynamic structure
  p <- 3
  mu0 <- rep(x = 0, times = p)
  sigma0 <- 0.001 * diag(p)
  sigma0_l <- t(chol(sigma0))
  alpha <- rep(x = 0, times = p)
  beta <- 0.50 * diag(p)
  psi <- 0.001 * diag(p)
  psi_l <- t(chol(psi))

  library(simStateSpace)
  ssm <- SimSSMVARFixed(
    n = n,
    time = time,
    mu0 = mu0,
    sigma0_l = sigma0_l,
    alpha = alpha,
    beta = beta,
    psi_l = psi_l,
    type = 0
  )
  data <- as.data.frame(ssm)
  ScaleByID(
    data = data,
    id = "id",
    time = "time",
    observed = paste0("y", 1:p)
  )
}
#>    id time         y1            y2          y3
#> 1   1    0 -0.4219779 -0.1290371363  0.99309366
#> 2   1    1  1.2344905 -1.5169034100  0.90297298
#> 3   1    2  0.2223925  0.9902754892  0.18426649
#> 4   1    3  0.4080190  0.8211679034 -1.05686493
#> 5   1    4 -1.4429241 -0.1655028462 -1.02346820
#> 6   2    0  1.0222882  0.5627105814  0.20465854
#> 7   2    1  0.1118914  1.3400201575  1.27732733
#> 8   2    2 -1.4830830 -0.4223332895 -0.08709119
#> 9   2    3  0.7584059 -0.1863264166  0.12294870
#> 10  2    4 -0.4095025 -1.2940710328 -1.51784338
#> 11  3    0  0.3176618 -1.5385111239 -1.50814893
#> 12  3    1  1.3877048 -0.1294458249 -0.02380892
#> 13  3    2  0.1836168  1.1973495717  1.19770254
#> 14  3    3 -1.2233483  0.4248368670 -0.17533785
#> 15  3    4 -0.6656352  0.0457705102  0.50959317
#> 16  4    0 -0.9895304  1.4087083945  1.13479101
#> 17  4    1 -0.5026359 -0.2993291562  0.15926771
#> 18  4    2  0.1917089 -0.3944157246 -1.51393066
#> 19  4    3  1.6212693  0.5128034087 -0.32060165
#> 20  4    4 -0.3208118 -1.2277669224  0.54047358
#> 21  5    0 -1.0963066 -0.8824085465 -0.51149142
#> 22  5    1  0.6438298 -1.0977846358  1.20934331
#> 23  5    2  0.1921786  0.0004827523 -1.41402392
#> 24  5    3  1.2055059  1.1580769792  0.25820995
#> 25  5    4 -0.9452078  0.8216334509  0.45796209
```
