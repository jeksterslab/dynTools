## ---- test-dynTools-insert-na
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "InsertNA",
        "creates a complete ID by time grid and inserts missing rows"
      ),
      {
        data <- data.frame(
          id = c(2L, 1L, 1L, 2L),
          time = c(3L, 1L, 3L, 1L),
          y = c(23, 11, 13, 21),
          cov = c(203, 101, 103, 201),
          extra = 1:4
        )

        out <- InsertNA(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          covariates = "cov",
          delta_t = 1
        )

        expected <- data.frame(
          id = c(1L, 1L, 1L, 2L, 2L, 2L),
          time = c(1L, 2L, 3L, 1L, 2L, 3L),
          y = c(11, NA, 13, 21, NA, 23),
          cov = c(101, NA, 103, 201, NA, 203)
        )

        testthat::expect_equal(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        "InsertNA",
        "includes empirical times not on the delta_t grid"
      ),
      {
        data <- data.frame(
          id = c(1L, 1L),
          time = c(1, 2.5),
          y = c(10, 25)
        )

        out <- InsertNA(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          delta_t = 1
        )

        testthat::expect_equal(out$time, c(1, 2, 2.5))
        testthat::expect_equal(out$y, c(10, NA, 25))
      }
    )

    testthat::test_that(
      paste(
        text,
        "InsertNA",
        "requires positive delta_t"
      ),
      {
        data <- data.frame(
          id = 1L,
          time = 1L,
          y = 1
        )

        testthat::expect_error(
          InsertNA(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            delta_t = 0
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "InsertNA",
        "requires unique id-time combinations"
      ),
      {
        data <- data.frame(
          id = c(1L, 1L),
          time = c(1L, 1L),
          y = c(10, 11)
        )

        testthat::expect_error(
          InsertNA(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            delta_t = 1
          ),
          regexp = "requires unique `id`-`time` combinations"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "InsertNA",
        "handles empty data frames"
      ),
      {
        data <- data.frame(
          id = integer(0),
          time = integer(0),
          y = numeric(0),
          cov = numeric(0),
          extra = integer(0)
        )

        out <- InsertNA(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          covariates = "cov",
          delta_t = 1
        )

        expected <- data.frame(
          id = integer(0),
          time = integer(0),
          y = numeric(0),
          cov = numeric(0)
        )

        testthat::expect_identical(out, expected)
      }
    )
  },
  text = "test-dynTools-insert-na"
)
