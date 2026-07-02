## ---- test-dynTools-regularize-time-smallest-delta-t-by-id
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    set.seed(42)

    if (!identical(Sys.getenv("NOT_CRAN"), "true") && !interactive()) {
      message("CRAN: tests skipped.")
      # nolint start
      return(invisible(NULL))
      # nolint end
    }

    testthat::test_that(
      paste(
        text,
        "RegularizeTimeDeltaTByID",
        "regularizes time by global smallest delta_t"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 1, 2, 2, 2),
          time = c(0, 2, 4, 0, 1, 2),
          y = c(1, 2, 3, 10, 11, 12)
        )

        result <- RegularizeTimeDeltaTByID(
          data = data,
          id = "id",
          time = "time"
        )

        testthat::expect_equal(
          attr(result, "delta_t"),
          1
        )

        testthat::expect_equal(
          result$id,
          c(1, 1, 1, 1, 1, 2, 2, 2)
        )

        testthat::expect_equal(
          result$time,
          c(0, 1, 2, 3, 4, 0, 1, 2)
        )

        testthat::expect_equal(
          result$y,
          c(1, NA, 2, NA, 3, 10, 11, 12)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "SmallestDeltaTByID",
        "computes the global smallest positive delta_t"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 1, 2, 2, 2),
          time = c(0, 2, 4, 0, 0.5, 1.5),
          y = 1:6
        )

        testthat::expect_equal(
          SmallestDeltaTByID(
            data = data,
            id = "id",
            time = "time"
          ),
          0.5
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "RegularizeTimeDeltaTByID",
        "checks duplicate ID-time rows"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 1),
          time = c(0, 0, 1),
          y = c(1, 2, 3)
        )

        testthat::expect_error(
          RegularizeTimeDeltaTByID(
            data = data,
            id = "id",
            time = "time"
          ),
          "Each `id` and `time` combination must be unique.",
          fixed = TRUE
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "SmallestDeltaTByID",
        "errors when no positive delta_t exists"
      ),
      {
        data <- data.frame(
          id = c(1, 2, 3),
          time = c(0, 0, 0),
          y = c(1, 2, 3)
        )

        testthat::expect_error(
          SmallestDeltaTByID(
            data = data,
            id = "id",
            time = "time"
          ),
          "Could not compute a positive `delta_t`.",
          fixed = TRUE
        )
      }
    )
  },
  text = "test-dynTools-regularize-time-smallest-delta-t-by-id"
)
