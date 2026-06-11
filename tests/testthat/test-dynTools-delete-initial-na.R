## ---- test-dynTools-delete-initial-na
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "DeleteInitialNA",
        "deletes leading incomplete rows by ID"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1L, 1L, 1L, 2L, 2L, 2L, 3L, 3L),
          time = c(1L, 2L, 3L, 1L, 2L, 3L, 1L, 2L),
          y = c(NA, NA, 3, NA, 20, NA, NA, NA),
          cov = c(1, 2, 3, NA, 5, 6, 7, 8)
        )

        out <- DeleteInitialNA(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          covariates = "cov"
        )

        expected <- data.frame(
          id = c(1L, 2L, 2L),
          time = c(3L, 2L, 3L),
          y = c(3, 20, NA),
          cov = c(3, 5, 6)
        )

        testthat::expect_identical(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        "DeleteInitialNA",
        "leaves later missing rows after the first complete row"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1L, 1L, 1L),
          time = c(1L, 2L, 3L),
          y = c(1, NA, 3)
        )

        out <- DeleteInitialNA(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_identical(out, data)
      }
    )

    testthat::test_that(
      paste(
        text,
        "DeleteInitialNA",
        "handles empty data frames"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = integer(0),
          time = integer(0),
          y = numeric(0)
        )

        out <- DeleteInitialNA(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_identical(out, data)
      }
    )
  },
  text = "test-dynTools-delete-initial-na"
)
