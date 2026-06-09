## ---- test-dynTools-check-dyn-data
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "CheckDynData",
        "accepts valid dynamic data"
      ),
      {
        data <- data.frame(
          id = rep(1:2, each = 3),
          time = rep(1:3, times = 2),
          y1 = seq_len(6),
          y2 = seq_len(6) + 10,
          x = rep(c(0, 1), each = 3),
          stringsAsFactors = FALSE
        )

        testthat::expect_true(
          CheckDynData(
            data = data,
            id = "id",
            time = "time",
            observed = c("y1", "y2"),
            covariates = "x"
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "CheckDynData",
        "rejects malformed dynamic data"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 1),
          time = c(1, 1, 2),
          y = c(1, 2, 3),
          z = c("a", "b", "c"),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          CheckDynData(
            data = data,
            id = "id",
            time = "time",
            observed = "missing"
          ),
          "missing from `data`"
        )

        testthat::expect_error(
          CheckDynData(
            data = data,
            id = "id",
            time = "time",
            observed = "y"
          ),
          "unique `id`-`time`"
        )

        testthat::expect_error(
          CheckDynData(
            data = data,
            id = "id",
            time = "time",
            observed = "z",
            require_unique = FALSE
          ),
          "Observed variables must be numeric"
        )

        testthat::expect_error(
          CheckDynData(
            data = data.frame(
              id = c(1, 1, 2),
              time = c(1, 2, 1),
              y = c(1, 2, 3),
              stringsAsFactors = FALSE
            ),
            id = "id",
            time = "time",
            observed = "y",
            min_rows = 2L
          ),
          "too few rows"
        )
      }
    )
  },
  text = "test-dynTools-check-dyn-data"
)
