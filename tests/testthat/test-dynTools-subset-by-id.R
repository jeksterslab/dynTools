## ---- test-dynTools-subset-by-id
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "SubsetByID",
        "returns a list split by sorted IDs"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(2L, 1L, 2L, 1L),
          time = c(2L, 1L, 1L, 2L),
          y = c(22, 11, 21, 12),
          cov = c("d", "a", "c", "b"),
          extra = 1:4
        )

        out <- SubsetByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          covariates = "cov"
        )

        testthat::expect_identical(
          out[["1"]],
          data.frame(
            id = c(1L, 1L),
            time = c(1L, 2L),
            y = c(11, 12),
            cov = c("a", "b")
          )
        )
        testthat::expect_identical(
          out[["2"]],
          data.frame(
            id = c(2L, 2L),
            time = c(1L, 2L),
            y = c(21, 22),
            cov = c("c", "d")
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "SubsetByID",
        "handles empty data frames"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = integer(0),
          time = integer(0),
          y = numeric(0)
        )

        out <- SubsetByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_length(out, 0L)
      }
    )

    testthat::test_that(
      paste(
        text,
        "SubsetByID",
        "requires data to be a data frame"
      ),
      {
        testthat::skip_on_cran()

        testthat::expect_error(
          SubsetByID(
            data = matrix(1:4, ncol = 2),
            id = "id",
            time = "time",
            observed = "y"
          )
        )
      }
    )
  },
  text = "test-dynTools-subset-by-id"
)
