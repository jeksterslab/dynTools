## ---- test-dynTools-delta-t-by-id
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "DeltaTByID",
        "summarizes within-ID time intervals"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(2, 1, 1, 2, 1, 2),
          time = c(3, 4, 1, 4, 2, 1),
          y = c(23, 14, 11, 24, 12, 21),
          stringsAsFactors = FALSE
        )

        out <- DeltaTByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        expected <- data.frame(
          id = c(1, 2),
          n_rows = c(3L, 3L),
          n_intervals = c(2L, 2L),
          time_min = c(1, 1),
          time_max = c(4, 4),
          min_delta_t = c(1, 1),
          median_delta_t = c(1.5, 1.5),
          max_delta_t = c(2, 2),
          n_unique_delta_t = c(2L, 2L),
          regular = c(FALSE, FALSE)
        )

        testthat::expect_identical(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        "DeltaTByID",
        "detects regular time intervals"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = rep(1:2, each = 3),
          time = rep(1:3, times = 2),
          y = 1:6,
          stringsAsFactors = FALSE
        )

        out <- DeltaTByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_true(all(out$regular))
        testthat::expect_identical(out$n_unique_delta_t, c(1L, 1L))
        testthat::expect_identical(out$min_delta_t, c(1, 1))
        testthat::expect_identical(out$max_delta_t, c(1, 1))
      }
    )

    testthat::test_that(
      paste(
        text,
        "DeltaTByID",
        "can use only id and time"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c("b", "a", "a", "b"),
          time = c(2, 1, 2, 4),
          y = c("w", "x", "y", "z"),
          stringsAsFactors = FALSE
        )

        out <- DeltaTByID(
          data = data,
          id = "id",
          time = "time"
        )

        testthat::expect_identical(out$id, c("a", "b"))
        testthat::expect_identical(out$n_intervals, c(1L, 1L))
        testthat::expect_identical(out$min_delta_t, c(1, 2))
      }
    )
  },
  text = "test-dynTools-delta-t-by-id"
)
