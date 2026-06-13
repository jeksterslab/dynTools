## ---- test-dynTools-regularize-time-by-id
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "RegularizeTimeByID",
        "creates a global time grid"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(2, 1, 2, 1),
          time = c(3, 1, 1, 2),
          y = c(23, 11, 21, 12),
          cov = c("b", "a", "b", "a"),
          stringsAsFactors = FALSE
        )

        out <- RegularizeTimeByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          covariates = "cov",
          delta_t = 1,
          grid = "global"
        )

        expected <- data.frame(
          id = c(1, 1, 1, 2, 2, 2),
          time = c(1, 2, 3, 1, 2, 3),
          y = c(11, 12, NA, 21, NA, 23),
          cov = c("a", "a", NA, "b", NA, "b"),
          stringsAsFactors = FALSE
        )

        testthat::expect_identical(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        "RegularizeTimeByID",
        "creates ID-specific time grids"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(2, 1, 2, 1),
          time = c(3, 1, 1, 2),
          y = c(23, 11, 21, 12),
          stringsAsFactors = FALSE
        )

        out <- RegularizeTimeByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          delta_t = 1,
          grid = "by_id"
        )

        expected <- data.frame(
          id = c(1, 1, 2, 2, 2),
          time = c(1, 2, 1, 2, 3),
          y = c(11, 12, 21, NA, 23),
          stringsAsFactors = FALSE
        )

        testthat::expect_identical(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        "RegularizeTimeByID",
        "preserves empirical times not on the grid"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1),
          time = c(1.0, 1.7),
          y = c(10, 17),
          stringsAsFactors = FALSE
        )

        out <- RegularizeTimeByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          delta_t = 0.5,
          grid = "by_id",
          method = "preserve"
        )

        testthat::expect_identical(out$time, c(1.0, 1.5, 1.7))
        testthat::expect_identical(out$y, c(10, NA, 17))
      }
    )

    testthat::test_that(
      paste(
        text,
        "RegularizeTimeByID",
        "snaps empirical times to the grid"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1),
          time = c(1.0, 1.7),
          y = c(10, 17),
          stringsAsFactors = FALSE
        )

        out <- RegularizeTimeByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          delta_t = 0.5,
          grid = "by_id",
          method = "snap"
        )

        expected <- data.frame(
          id = c(1, 1),
          time = c(1.0, 1.5),
          y = c(10, 17),
          stringsAsFactors = FALSE
        )

        testthat::expect_identical(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        "RegularizeTimeByID",
        "snaps upward when observations are closer to the next grid point"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1),
          time = c(1.0, 1.9),
          y = c(10, 19),
          stringsAsFactors = FALSE
        )

        out <- RegularizeTimeByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          delta_t = 0.5,
          grid = "by_id",
          method = "snap"
        )

        expected <- data.frame(
          id = c(1, 1, 1),
          time = c(1.0, 1.5, 2.0),
          y = c(10, NA, 19),
          stringsAsFactors = FALSE
        )

        testthat::expect_identical(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        "RegularizeTimeByID",
        "resolves duplicate rows created by snapping"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(1.0, 1.24, 1.26),
          y = c(10, 124, 126),
          stringsAsFactors = FALSE
        )

        out <- RegularizeTimeByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          delta_t = 0.5,
          grid = "by_id",
          method = "snap"
        )

        expected <- data.frame(
          id = c(1, 1),
          time = c(1.0, 1.5),
          y = c(10, 126),
          stringsAsFactors = FALSE
        )

        testthat::expect_identical(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        "RegularizeTimeByID",
        "requires unique id-time combinations"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1),
          time = c(1, 1),
          y = c(10, 11),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          RegularizeTimeByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            delta_t = 1
          ),
          "unique"
        )
      }
    )
  },
  text = "test-dynTools-regularize-time-by-id"
)
