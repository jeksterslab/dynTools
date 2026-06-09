# Print Method for Object of Class `dynutillist`

Print Method for Object of Class `dynutillist`

## Usage

``` r
# S3 method for class 'dynutillist'
print(x, ...)
```

## Arguments

- x:

  an object of class `dynutillist`.

- ...:

  further arguments.

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
  out <- SubsetByID(
    data = data,
    id = "id",
    time = "time",
    observed = paste0("y", 1:p)
  )
  print(out)
}
#> $`1`
#>   id time           y1           y2          y3
#> 1  1    0 -0.016807560  0.025970291  0.07012192
#> 2  1    1  0.004398973 -0.006784527  0.06630984
#> 3  1    2 -0.008558165  0.052387016  0.03590879
#> 4  1    3 -0.006181726  0.048395934 -0.01659066
#> 5  1    4 -0.029877975  0.025109669 -0.01517799
#> 
#> $`2`
#>   id time          y1            y2           y3
#> 1  2    0 -0.00611928  0.0387721989  0.018996185
#> 2  2    1 -0.03299718  0.0689297674  0.034667714
#> 3  2    2 -0.08008605  0.0005550857  0.014733765
#> 4  2    3 -0.01390995  0.0097115321  0.017802417
#> 5  2    4 -0.04839044 -0.0332660475 -0.006169308
#> 
#> $`3`
#>   id time          y1            y2            y3
#> 1  3    0  0.01621385 -0.0300663706 -0.0541857866
#> 2  3    1  0.05650023 -0.0026360905 -0.0148648209
#> 3  3    2  0.01116715  0.0231926410  0.0174936750
#> 4  3    3 -0.04180412  0.0081541330 -0.0188789037
#> 5  3    4 -0.02080661  0.0007748466 -0.0007347123
#> 
#> $`4`
#>   id time           y1           y2           y3
#> 1  4    0 -0.041799361  0.043181148  0.046482157
#> 2  4    1 -0.026059618  0.013645768  0.006262266
#> 3  4    2 -0.003613672  0.012001531 -0.062722101
#> 4  4    3  0.042599445  0.027689161 -0.013522289
#> 5  4    4 -0.020181828 -0.002408775  0.021979018
#> 
#> $`5`
#>   id time           y1           y2          y3
#> 1  5    0 0.0002017724 -0.002808276  0.01143842
#> 2  5    1 0.0509683787 -0.010963624  0.07159599
#> 3  5    2 0.0377919404  0.030622944 -0.02011265
#> 4  5    3 0.0673546742  0.074455959  0.03834592
#> 5  5    4 0.0046099160  0.061716319  0.04532893
#> 
```
