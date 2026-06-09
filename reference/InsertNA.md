# Insert NAs for Missing Observations

The function creates a sequence of time values. It starts with the
smallest time value as the starting point and the largest time value as
the endpoint. The sequence is incremented by `delta_t`. This new
sequence is combined with the existing empirical time values. For any
specific time value where there are no observations, NAs are inserted.

## Usage

``` r
InsertNA(data, id, time, observed, covariates = NULL, delta_t, ncores = NULL)
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

- delta_t:

  Positive number. Time interval.

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
  InsertNA(
    data = data,
    id = "id",
    time = "time",
    observed = paste0("y", 1:p),
    delta_t = 0.10
  )
}
#>     id time            y1            y2            y3
#> 1    1  0.0 -0.0168075605  0.0259702907  0.0701219166
#> 2    1  0.1            NA            NA            NA
#> 3    1  0.2            NA            NA            NA
#> 4    1  0.3            NA            NA            NA
#> 5    1  0.4            NA            NA            NA
#> 6    1  0.5            NA            NA            NA
#> 7    1  0.6            NA            NA            NA
#> 8    1  0.7            NA            NA            NA
#> 9    1  0.8            NA            NA            NA
#> 10   1  0.9            NA            NA            NA
#> 11   1  1.0  0.0043989735 -0.0067845275  0.0663098413
#> 12   1  1.1            NA            NA            NA
#> 13   1  1.2            NA            NA            NA
#> 14   1  1.3            NA            NA            NA
#> 15   1  1.4            NA            NA            NA
#> 16   1  1.5            NA            NA            NA
#> 17   1  1.6            NA            NA            NA
#> 18   1  1.7            NA            NA            NA
#> 19   1  1.8            NA            NA            NA
#> 20   1  1.9            NA            NA            NA
#> 21   1  2.0 -0.0085581649  0.0523870156  0.0359087914
#> 22   1  2.1            NA            NA            NA
#> 23   1  2.2            NA            NA            NA
#> 24   1  2.3            NA            NA            NA
#> 25   1  2.4            NA            NA            NA
#> 26   1  2.5            NA            NA            NA
#> 27   1  2.6            NA            NA            NA
#> 28   1  2.7            NA            NA            NA
#> 29   1  2.8            NA            NA            NA
#> 30   1  2.9            NA            NA            NA
#> 31   1  3.0 -0.0061817260  0.0483959335 -0.0165906623
#> 32   1  3.1            NA            NA            NA
#> 33   1  3.2            NA            NA            NA
#> 34   1  3.3            NA            NA            NA
#> 35   1  3.4            NA            NA            NA
#> 36   1  3.5            NA            NA            NA
#> 37   1  3.6            NA            NA            NA
#> 38   1  3.7            NA            NA            NA
#> 39   1  3.8            NA            NA            NA
#> 40   1  3.9            NA            NA            NA
#> 41   1  4.0 -0.0298779752  0.0251096691 -0.0151779919
#> 42   2  0.0 -0.0061192799  0.0387721989  0.0189961850
#> 43   2  0.1            NA            NA            NA
#> 44   2  0.2            NA            NA            NA
#> 45   2  0.3            NA            NA            NA
#> 46   2  0.4            NA            NA            NA
#> 47   2  0.5            NA            NA            NA
#> 48   2  0.6            NA            NA            NA
#> 49   2  0.7            NA            NA            NA
#> 50   2  0.8            NA            NA            NA
#> 51   2  0.9            NA            NA            NA
#> 52   2  1.0 -0.0329971795  0.0689297674  0.0346677144
#> 53   2  1.1            NA            NA            NA
#> 54   2  1.2            NA            NA            NA
#> 55   2  1.3            NA            NA            NA
#> 56   2  1.4            NA            NA            NA
#> 57   2  1.5            NA            NA            NA
#> 58   2  1.6            NA            NA            NA
#> 59   2  1.7            NA            NA            NA
#> 60   2  1.8            NA            NA            NA
#> 61   2  1.9            NA            NA            NA
#> 62   2  2.0 -0.0800860506  0.0005550857  0.0147337653
#> 63   2  2.1            NA            NA            NA
#> 64   2  2.2            NA            NA            NA
#> 65   2  2.3            NA            NA            NA
#> 66   2  2.4            NA            NA            NA
#> 67   2  2.5            NA            NA            NA
#> 68   2  2.6            NA            NA            NA
#> 69   2  2.7            NA            NA            NA
#> 70   2  2.8            NA            NA            NA
#> 71   2  2.9            NA            NA            NA
#> 72   2  3.0 -0.0139099509  0.0097115321  0.0178024165
#> 73   2  3.1            NA            NA            NA
#> 74   2  3.2            NA            NA            NA
#> 75   2  3.3            NA            NA            NA
#> 76   2  3.4            NA            NA            NA
#> 77   2  3.5            NA            NA            NA
#> 78   2  3.6            NA            NA            NA
#> 79   2  3.7            NA            NA            NA
#> 80   2  3.8            NA            NA            NA
#> 81   2  3.9            NA            NA            NA
#> 82   2  4.0 -0.0483904352 -0.0332660475 -0.0061693084
#> 83   3  0.0  0.0162138501 -0.0300663706 -0.0541857866
#> 84   3  0.1            NA            NA            NA
#> 85   3  0.2            NA            NA            NA
#> 86   3  0.3            NA            NA            NA
#> 87   3  0.4            NA            NA            NA
#> 88   3  0.5            NA            NA            NA
#> 89   3  0.6            NA            NA            NA
#> 90   3  0.7            NA            NA            NA
#> 91   3  0.8            NA            NA            NA
#> 92   3  0.9            NA            NA            NA
#> 93   3  1.0  0.0565002345 -0.0026360905 -0.0148648209
#> 94   3  1.1            NA            NA            NA
#> 95   3  1.2            NA            NA            NA
#> 96   3  1.3            NA            NA            NA
#> 97   3  1.4            NA            NA            NA
#> 98   3  1.5            NA            NA            NA
#> 99   3  1.6            NA            NA            NA
#> 100  3  1.7            NA            NA            NA
#> 101  3  1.8            NA            NA            NA
#> 102  3  1.9            NA            NA            NA
#> 103  3  2.0  0.0111671458  0.0231926410  0.0174936750
#> 104  3  2.1            NA            NA            NA
#> 105  3  2.2            NA            NA            NA
#> 106  3  2.3            NA            NA            NA
#> 107  3  2.4            NA            NA            NA
#> 108  3  2.5            NA            NA            NA
#> 109  3  2.6            NA            NA            NA
#> 110  3  2.7            NA            NA            NA
#> 111  3  2.8            NA            NA            NA
#> 112  3  2.9            NA            NA            NA
#> 113  3  3.0 -0.0418041237  0.0081541330 -0.0188789037
#> 114  3  3.1            NA            NA            NA
#> 115  3  3.2            NA            NA            NA
#> 116  3  3.3            NA            NA            NA
#> 117  3  3.4            NA            NA            NA
#> 118  3  3.5            NA            NA            NA
#> 119  3  3.6            NA            NA            NA
#> 120  3  3.7            NA            NA            NA
#> 121  3  3.8            NA            NA            NA
#> 122  3  3.9            NA            NA            NA
#> 123  3  4.0 -0.0208066072  0.0007748466 -0.0007347123
#> 124  4  0.0 -0.0417993615  0.0431811476  0.0464821572
#> 125  4  0.1            NA            NA            NA
#> 126  4  0.2            NA            NA            NA
#> 127  4  0.3            NA            NA            NA
#> 128  4  0.4            NA            NA            NA
#> 129  4  0.5            NA            NA            NA
#> 130  4  0.6            NA            NA            NA
#> 131  4  0.7            NA            NA            NA
#> 132  4  0.8            NA            NA            NA
#> 133  4  0.9            NA            NA            NA
#> 134  4  1.0 -0.0260596182  0.0136457676  0.0062622657
#> 135  4  1.1            NA            NA            NA
#> 136  4  1.2            NA            NA            NA
#> 137  4  1.3            NA            NA            NA
#> 138  4  1.4            NA            NA            NA
#> 139  4  1.5            NA            NA            NA
#> 140  4  1.6            NA            NA            NA
#> 141  4  1.7            NA            NA            NA
#> 142  4  1.8            NA            NA            NA
#> 143  4  1.9            NA            NA            NA
#> 144  4  2.0 -0.0036136722  0.0120015310 -0.0627221010
#> 145  4  2.1            NA            NA            NA
#> 146  4  2.2            NA            NA            NA
#> 147  4  2.3            NA            NA            NA
#> 148  4  2.4            NA            NA            NA
#> 149  4  2.5            NA            NA            NA
#> 150  4  2.6            NA            NA            NA
#> 151  4  2.7            NA            NA            NA
#> 152  4  2.8            NA            NA            NA
#> 153  4  2.9            NA            NA            NA
#> 154  4  3.0  0.0425994450  0.0276891614 -0.0135222887
#> 155  4  3.1            NA            NA            NA
#> 156  4  3.2            NA            NA            NA
#> 157  4  3.3            NA            NA            NA
#> 158  4  3.4            NA            NA            NA
#> 159  4  3.5            NA            NA            NA
#> 160  4  3.6            NA            NA            NA
#> 161  4  3.7            NA            NA            NA
#> 162  4  3.8            NA            NA            NA
#> 163  4  3.9            NA            NA            NA
#> 164  4  4.0 -0.0201818279 -0.0024087753  0.0219790184
#> 165  5  0.0  0.0002017724 -0.0028082763  0.0114384154
#> 166  5  0.1            NA            NA            NA
#> 167  5  0.2            NA            NA            NA
#> 168  5  0.3            NA            NA            NA
#> 169  5  0.4            NA            NA            NA
#> 170  5  0.5            NA            NA            NA
#> 171  5  0.6            NA            NA            NA
#> 172  5  0.7            NA            NA            NA
#> 173  5  0.8            NA            NA            NA
#> 174  5  0.9            NA            NA            NA
#> 175  5  1.0  0.0509683787 -0.0109636240  0.0715959928
#> 176  5  1.1            NA            NA            NA
#> 177  5  1.2            NA            NA            NA
#> 178  5  1.3            NA            NA            NA
#> 179  5  1.4            NA            NA            NA
#> 180  5  1.5            NA            NA            NA
#> 181  5  1.6            NA            NA            NA
#> 182  5  1.7            NA            NA            NA
#> 183  5  1.8            NA            NA            NA
#> 184  5  1.9            NA            NA            NA
#> 185  5  2.0  0.0377919404  0.0306229441 -0.0201126499
#> 186  5  2.1            NA            NA            NA
#> 187  5  2.2            NA            NA            NA
#> 188  5  2.3            NA            NA            NA
#> 189  5  2.4            NA            NA            NA
#> 190  5  2.5            NA            NA            NA
#> 191  5  2.6            NA            NA            NA
#> 192  5  2.7            NA            NA            NA
#> 193  5  2.8            NA            NA            NA
#> 194  5  2.9            NA            NA            NA
#> 195  5  3.0  0.0673546742  0.0744559593  0.0383459206
#> 196  5  3.1            NA            NA            NA
#> 197  5  3.2            NA            NA            NA
#> 198  5  3.3            NA            NA            NA
#> 199  5  3.4            NA            NA            NA
#> 200  5  3.5            NA            NA            NA
#> 201  5  3.6            NA            NA            NA
#> 202  5  3.7            NA            NA            NA
#> 203  5  3.8            NA            NA            NA
#> 204  5  3.9            NA            NA            NA
#> 205  5  4.0  0.0046099160  0.0617163188  0.0453289300
```
