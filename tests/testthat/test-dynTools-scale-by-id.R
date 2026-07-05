## ---- test-dynTools-scale-by-id
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
        "ScaleByID",
        "mean-centers selected variables by ID"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1L, 1L, 1L, 2L, 2L, 2L),
          time = c(1L, 2L, 3L, 1L, 2L, 3L),
          y = c(1, 2, 3, 10, 20, NA),
          x = c(2, 4, 6, 5, 5, 5),
          skip_obs = c(11, 12, 13, 14, 15, 16),
          cov = c(10, 20, 30, 100, NA, 300),
          skip_cov = c(1, 2, 3, 4, 5, 6)
        )

        out <- ScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y", "x", "skip_obs"),
          covariates = c("cov", "skip_cov"),
          scale = FALSE,
          obs_skip = "skip_obs",
          cov_skip = "skip_cov"
        )

        expected <- data.frame(
          id = c(1L, 1L, 1L, 2L, 2L, 2L),
          time = c(1L, 2L, 3L, 1L, 2L, 3L),
          y = c(-1, 0, 1, -5, 5, NA),
          x = c(-2, 0, 2, 0, 0, 0),
          skip_obs = c(11, 12, 13, 14, 15, 16),
          cov = c(-10, 0, 10, -100, NA, 100),
          skip_cov = c(1, 2, 3, 4, 5, 6)
        )

        testthat::expect_equal(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        "ScaleByID",
        "standardizes selected variables by ID"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1L, 1L, 1L, 2L, 2L, 2L),
          time = c(1L, 2L, 3L, 1L, 2L, 3L),
          y = c(1, 2, 3, 10, 20, NA),
          x = c(2, 4, 6, 5, 5, 5),
          cov = c(10, 20, 30, 100, NA, 300)
        )

        out <- ScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y", "x"),
          covariates = "cov",
          scale = TRUE
        )

        expected <- data.frame(
          id = c(1L, 1L, 1L, 2L, 2L, 2L),
          time = c(1L, 2L, 3L, 1L, 2L, 3L),
          y = c(-1, 0, 1, -sqrt(0.5), sqrt(0.5), NA),
          x = c(-1, 0, 1, 0, 0, 0),
          cov = c(-1, 0, 1, -sqrt(0.5), NA, sqrt(0.5))
        )

        testthat::expect_equal(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        "ScaleByID",
        "handles no transformable variables"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1L, 1L, 2L),
          time = c(1L, 2L, 1L),
          y = c(1, 2, 3)
        )

        out <- ScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          scale = TRUE,
          obs_skip = "y"
        )

        testthat::expect_identical(out, data)
      }
    )


    testthat::test_that(
      paste(
        text,
        "ScaleByID",
        "handles one finite value within ID without producing NaN"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1L, 1L),
          time = c(1L, 2L),
          y = c(10, NA)
        )

        out <- ScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_equal(
          out$y,
          c(0, NA)
        )

        testthat::expect_false(
          any(is.nan(out$y))
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ScaleByID",
        "converts non-finite selected values to NA"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1L, 1L, 2L, 2L),
          time = c(1L, 2L, 1L, 2L),
          y = c(1, Inf, NaN, NA)
        )

        out <- ScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_equal(
          out$y,
          c(0, NA, NA, NA)
        )

        testthat::expect_false(
          any(is.infinite(out$y))
        )
        testthat::expect_false(
          any(is.nan(out$y))
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ScaleByID",
        "leaves all non-finite selected values as NA"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1L, 1L, 2L, 2L),
          time = c(1L, 2L, 1L, 2L),
          y = c(NA, NaN, Inf, -Inf)
        )

        out <- ScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_equal(
          out$y,
          rep(NA_real_, 4L)
        )

        testthat::expect_true(
          all(is.na(out$y))
        )
        testthat::expect_false(
          any(is.infinite(out$y))
        )
        testthat::expect_false(
          any(is.nan(out$y))
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ScaleByID",
        "handles empty data frames"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = integer(0),
          time = integer(0),
          y = numeric(0)
        )

        out <- ScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_identical(out, data)
      }
    )
  },
  text = "test-dynTools-scale-by-id"
)
