## ---- test-dynTools-lag-by-id
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "LagByID",
        "creates lags within ID and does not cross ID boundaries"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c("b", "a", "a", "b", "a"),
          time = c(2, 3, 1, 1, 2),
          y = c(200, 30, 10, 100, 20),
          x = c(2, 3, 1, 1, 2),
          c = c(0, 1, 1, 0, 1),
          stringsAsFactors = FALSE
        )

        out <- LagByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y", "x"),
          covariates = "c",
          lags = c(2, 1)
        )

        expected <- data.frame(
          id = c("a", "a", "a", "b", "b"),
          time = c(1, 2, 3, 1, 2),
          y = c(10, 20, 30, 100, 200),
          x = c(1, 2, 3, 1, 2),
          c = c(1, 1, 1, 0, 0),
          lag1_y = c(NA, 10, 20, NA, 100),
          lag1_x = c(NA, 1, 2, NA, 1),
          lag2_y = c(NA, NA, 10, NA, NA),
          lag2_x = c(NA, NA, 1, NA, NA),
          stringsAsFactors = FALSE
        )

        testthat::expect_equal(
          out,
          expected
        )

        testthat::expect_identical(
          rownames(out),
          as.character(seq_len(nrow(out)))
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "LagByID",
        "validates lags and output names"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1),
          time = c(1, 2),
          y = c(1, 2),
          lag1_y = c(NA, 1),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          LagByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            lags = 0L
          ),
          "`lags` must be"
        )

        testthat::expect_error(
          LagByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            lags = 1L
          ),
          "already exist"
        )
      }
    )
  },
  text = "test-dynTools-lag-by-id"
)
