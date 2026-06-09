# Delete for NAs in Initial Row By ID

The function removes initial rows by ID if they contain missing values.
This process is repeated until the first row per ID no longer has
missing observations.

## Usage

``` r
DeleteInitialNA(data, id, time, observed, covariates = NULL, ncores = NULL)
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

- ncores:

  Positive integer. Number of cores to use. If `ncores = NULL`, use a
  single core. Consider using multiple cores when number of individuals
  is large.

## Value

Returns a data frame.

## See also

Other Dynamic Modeling Utility Functions:
[`CheckDynData()`](https://github.com/jeksterslab/dynTools/reference/CheckDynData.md),
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
[`ScaleByID()`](https://github.com/jeksterslab/dynTools/reference/ScaleByID.md),
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
  # Replace first row with NA
  data[1, paste0("y", 1:p)] <- NA
  DeleteInitialNA(
    data = data,
    id = "id",
    time = "time",
    observed = paste0("y", 1:p)
  )
}
#>    id time            y1            y2            y3
#> 1   1    1  0.0043989735 -0.0067845275  0.0663098413
#> 2   1    2 -0.0085581649  0.0523870156  0.0359087914
#> 3   1    3 -0.0061817260  0.0483959335 -0.0165906623
#> 4   1    4 -0.0298779752  0.0251096691 -0.0151779919
#> 5   2    0 -0.0061192799  0.0387721989  0.0189961850
#> 6   2    1 -0.0329971795  0.0689297674  0.0346677144
#> 7   2    2 -0.0800860506  0.0005550857  0.0147337653
#> 8   2    3 -0.0139099509  0.0097115321  0.0178024165
#> 9   2    4 -0.0483904352 -0.0332660475 -0.0061693084
#> 10  3    0  0.0162138501 -0.0300663706 -0.0541857866
#> 11  3    1  0.0565002345 -0.0026360905 -0.0148648209
#> 12  3    2  0.0111671458  0.0231926410  0.0174936750
#> 13  3    3 -0.0418041237  0.0081541330 -0.0188789037
#> 14  3    4 -0.0208066072  0.0007748466 -0.0007347123
#> 15  4    0 -0.0417993615  0.0431811476  0.0464821572
#> 16  4    1 -0.0260596182  0.0136457676  0.0062622657
#> 17  4    2 -0.0036136722  0.0120015310 -0.0627221010
#> 18  4    3  0.0425994450  0.0276891614 -0.0135222887
#> 19  4    4 -0.0201818279 -0.0024087753  0.0219790184
#> 20  5    0  0.0002017724 -0.0028082763  0.0114384154
#> 21  5    1  0.0509683787 -0.0109636240  0.0715959928
#> 22  5    2  0.0377919404  0.0306229441 -0.0201126499
#> 23  5    3  0.0673546742  0.0744559593  0.0383459206
#> 24  5    4  0.0046099160  0.0617163188  0.0453289300
```
