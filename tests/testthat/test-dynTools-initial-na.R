## ---- test-dynTools-initial-na
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "InitialNA",
        "returns IDs whose first row has missing values"
      ),
      {
        data <- data.frame(
          id = c(2L, 1L, 1L, 2L, 3L, 3L),
          time = c(1L, 2L, 1L, 2L, 1L, 2L),
          y = c(1, 3, NA, 4, 5, 6),
          cov = c(NA, 2, 1, 3, 4, NA)
        )

        with_cov <- InitialNA(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          covariates = "cov"
        )

        without_cov <- InitialNA(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_identical(with_cov, c(1L, 2L))
        testthat::expect_identical(without_cov, 1L)
      }
    )

    testthat::test_that(
      paste(
        text,
        "InitialNA",
        "returns an empty ID vector when no initial rows are missing"
      ),
      {
        data <- data.frame(
          id = c(1L, 1L, 2L, 2L),
          time = c(1L, 2L, 1L, 2L),
          y = c(1, NA, 3, 4)
        )

        out <- InitialNA(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_identical(out, integer(0))
      }
    )

    testthat::test_that(
      paste(
        text,
        "InitialNA",
        "handles empty data frames"
      ),
      {
        data <- data.frame(
          id = integer(0),
          time = integer(0),
          y = numeric(0)
        )

        out <- InitialNA(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_identical(out, integer(0))
      }
    )
  },
  text = "test-dynTools-initial-na"
)
