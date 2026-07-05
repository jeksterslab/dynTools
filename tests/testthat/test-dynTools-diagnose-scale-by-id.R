## ---- test-dynTools-diagnose-scale-by-id
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
        "DiagnoseScaleByID",
        "returns one row per ID-variable combination"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = rep(1:2, each = 3),
          time = rep(1:3, times = 2),
          y1 = c(-1, 0, 1, -2, 0, 2),
          y2 = c(2, 3, 4, 5, 6, 7),
          stringsAsFactors = FALSE
        )

        out <- DiagnoseScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2")
        )

        testthat::expect_s3_class(
          out,
          "data.frame"
        )

        testthat::expect_equal(
          nrow(out),
          4L
        )

        testthat::expect_equal(
          out$id,
          c(1, 1, 2, 2)
        )

        testthat::expect_equal(
          out$variable,
          c("y1", "y2", "y1", "y2")
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DiagnoseScaleByID",
        "computes within-ID diagnostics and projected z values"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(1, 2, 3),
          y = c(-1, 0, 1),
          stringsAsFactors = FALSE
        )

        out <- DiagnoseScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_equal(
          out$n_total,
          3L
        )

        testthat::expect_equal(
          out$n_finite,
          3L
        )

        testthat::expect_equal(
          out$mean,
          0,
          tolerance = 1e-12
        )

        testthat::expect_equal(
          out$sd,
          1,
          tolerance = 1e-12
        )

        testthat::expect_equal(
          out$min,
          -1,
          tolerance = 1e-12
        )

        testthat::expect_equal(
          out$max,
          1,
          tolerance = 1e-12
        )

        testthat::expect_equal(
          out$max_abs_z_after_scaling,
          1,
          tolerance = 1e-12
        )

        testthat::expect_equal(
          out$time_max_abs_z,
          1,
          tolerance = 1e-12
        )

        testthat::expect_equal(
          out$value_max_abs_z,
          -1,
          tolerance = 1e-12
        )

        testthat::expect_equal(
          out$row_max_abs_z,
          1L
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DiagnoseScaleByID",
        "flags zero and low within-ID standard deviations"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = rep(1:2, each = 3),
          time = rep(1:3, times = 2),
          y = c(2, 2, 2, 0, 0.01, 0.02),
          stringsAsFactors = FALSE
        )

        out <- DiagnoseScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          sd_min = 0.02
        )

        testthat::expect_true(
          out$flag_zero_sd[out$id == 1]
        )

        testthat::expect_false(
          out$flag_low_sd[out$id == 1]
        )

        testthat::expect_true(
          out$flag_low_sd[out$id == 2]
        )

        testthat::expect_true(
          all(out$flag)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DiagnoseScaleByID",
        "flags extreme projected standardized values"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = rep(1, 5),
          time = 1:5,
          y = c(0, 0, 0, 0, 10),
          stringsAsFactors = FALSE
        )

        out <- DiagnoseScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          z_cut = 1.5
        )

        testthat::expect_true(
          out$flag_extreme_z
        )

        testthat::expect_true(
          out$flag
        )

        testthat::expect_equal(
          out$time_max_abs_z,
          5,
          tolerance = 1e-12
        )

        testthat::expect_equal(
          out$value_max_abs_z,
          10,
          tolerance = 1e-12
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DiagnoseScaleByID",
        "can return only flagged ID-variable combinations"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = rep(1:2, each = 4),
          time = rep(1:4, times = 2),
          y = c(-1, 0, 0, 1, 0, 0, 0, 10),
          stringsAsFactors = FALSE
        )

        out <- DiagnoseScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          z_cut = 1.5,
          flagged_only = TRUE
        )

        testthat::expect_equal(
          nrow(out),
          1L
        )

        testthat::expect_equal(
          out$id,
          2
        )

        testthat::expect_true(
          out$flag_extreme_z
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DiagnoseScaleByID",
        "counts missing and non-finite observed values"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = rep(1, 5),
          time = 1:5,
          y = c(1, NA, Inf, NaN, 5),
          stringsAsFactors = FALSE
        )

        out <- DiagnoseScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_equal(
          out$n_na,
          2L
        )

        testthat::expect_equal(
          out$n_nan,
          1L
        )

        testthat::expect_equal(
          out$n_inf,
          1L
        )

        testthat::expect_equal(
          out$n_finite,
          2L
        )

        testthat::expect_equal(
          out$n_missing,
          3L
        )

        testthat::expect_true(
          out$flag_nonfinite
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DiagnoseScaleByID",
        "flags ID-variable combinations with too few finite values"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(1, 2, 3),
          y = c(1, NA, 3),
          stringsAsFactors = FALSE
        )

        out <- DiagnoseScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          min_n = 3L
        )

        testthat::expect_true(
          out$flag_low_n
        )

        testthat::expect_true(
          out$flag
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DiagnoseScaleByID",
        "allows sd_min to be NULL"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(1, 2, 3),
          y = c(0, 0.01, 0.02),
          stringsAsFactors = FALSE
        )

        out <- DiagnoseScaleByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          sd_min = NULL
        )

        testthat::expect_false(
          out$flag_low_sd
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DiagnoseScaleByID",
        "checks input arguments"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(1, 2, 3),
          y = c(1, 2, 3),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          DiagnoseScaleByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            sd_min = NA
          ),
          "`sd_min` must be `NULL` or a non-negative finite numeric scalar",
          fixed = TRUE
        )

        testthat::expect_error(
          DiagnoseScaleByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            z_cut = 0
          ),
          "`z_cut` must be a positive finite numeric scalar",
          fixed = TRUE
        )

        testthat::expect_error(
          DiagnoseScaleByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            min_n = 1.5
          ),
          "`min_n` must be a positive integer",
          fixed = TRUE
        )

        testthat::expect_error(
          DiagnoseScaleByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            flagged_only = NA
          ),
          "`flagged_only` must be `TRUE` or `FALSE`",
          fixed = TRUE
        )
      }
    )
  },
  text = "test-dynTools-diagnose-scale-by-id"
)
