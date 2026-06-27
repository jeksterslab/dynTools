## ---- test-dynTools-diagnostics-by-id
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
        "DiagnosticsByID",
        "computes ID-level row, duplicate, and gap diagnostics"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(
            rep(1, 4),
            rep(2, 3)
          ),
          time = c(
            1, 2, 4, 4,
            1, 3, 4
          ),
          y1 = c(
            1, 2, NA, 4,
            1, 1, 1
          ),
          y2 = c(
            NA, 2, NA, 5,
            2, 2, 2
          ),
          stringsAsFactors = FALSE
        )

        out <- DiagnosticsByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          extreme_cut = c(3, 4),
          sd_cut = 1
        )

        testthat::expect_equal(
          nrow(out),
          2L
        )

        id1 <- out[out$id == 1, , drop = FALSE]
        id2 <- out[out$id == 2, , drop = FALSE]

        testthat::expect_equal(id1$n_rows, 4L)
        testthat::expect_equal(id1$n_observed_rows, 3L)
        testthat::expect_equal(id1$n_complete_rows, 2L)
        testthat::expect_equal(id1$prop_all_missing, 1 / 4)
        testthat::expect_equal(id1$n_duplicate_id_time, 1L)
        testthat::expect_equal(id1$min_time, 1)
        testthat::expect_equal(id1$max_time, 4)
        testthat::expect_equal(id1$max_obs_gap, 2)
        testthat::expect_equal(id1$median_obs_gap, 1.5)
        testthat::expect_equal(id1$mean_obs_gap, 1.5)

        testthat::expect_equal(id2$n_rows, 3L)
        testthat::expect_equal(id2$n_observed_rows, 3L)
        testthat::expect_equal(id2$n_complete_rows, 3L)
        testthat::expect_equal(id2$prop_all_missing, 0)
        testthat::expect_equal(id2$n_duplicate_id_time, 0L)
        testthat::expect_equal(id2$min_time, 1)
        testthat::expect_equal(id2$max_time, 4)
        testthat::expect_equal(id2$max_obs_gap, 2)
        testthat::expect_equal(id2$median_obs_gap, 1.5)
        testthat::expect_equal(id2$mean_obs_gap, 1.5)
      }
    )

    testthat::test_that(
      paste(
        text,
        "DiagnosticsByID",
        "computes variable-level diagnostics and summaries"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(
            rep(1, 4),
            rep(2, 3)
          ),
          time = c(
            1, 2, 4, 4,
            1, 3, 4
          ),
          y1 = c(
            1, 2, NA, 4,
            1, 1, 1
          ),
          y2 = c(
            NA, 2, NA, 5,
            2, 2, 2
          ),
          stringsAsFactors = FALSE
        )

        out <- DiagnosticsByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          extreme_cut = c(3, 4),
          sd_cut = 1
        )

        id1 <- out[out$id == 1, , drop = FALSE]
        id2 <- out[out$id == 2, , drop = FALSE]

        testthat::expect_equal(id1$miss_y1, 1 / 4)
        testthat::expect_equal(id1$miss_y2, 2 / 4)
        testthat::expect_equal(id1$n_y1, 3L)
        testthat::expect_equal(id1$n_y2, 2L)
        testthat::expect_equal(
          id1$sd_y1,
          stats::sd(c(1, 2, 4)),
          tolerance = 1e-12
        )
        testthat::expect_equal(
          id1$sd_y2,
          stats::sd(c(2, 5)),
          tolerance = 1e-12
        )
        testthat::expect_equal(id1$maxabs_y1, 4)
        testthat::expect_equal(id1$maxabs_y2, 5)

        testthat::expect_equal(id1$n_abs_gt3_y1, 1L)
        testthat::expect_equal(id1$n_abs_gt4_y1, 0L)
        testthat::expect_equal(id1$n_abs_gt3_y2, 1L)
        testthat::expect_equal(id1$n_abs_gt4_y2, 1L)
        testthat::expect_equal(id1$n_abs_gt3_total, 2L)
        testthat::expect_equal(id1$n_abs_gt4_total, 1L)

        testthat::expect_equal(
          id1$min_sd,
          stats::sd(c(1, 2, 4)),
          tolerance = 1e-12
        )
        testthat::expect_equal(
          id1$median_sd,
          stats::median(
            c(
              stats::sd(c(1, 2, 4)),
              stats::sd(c(2, 5))
            )
          ),
          tolerance = 1e-12
        )
        testthat::expect_equal(id1$min_sd_variable, "y1")
        testthat::expect_equal(id1$max_abs_any, 5)
        testthat::expect_equal(id1$max_abs_variable, "y2")

        testthat::expect_equal(id2$sd_y1, 0)
        testthat::expect_equal(id2$sd_y2, 0)
        testthat::expect_equal(id2$min_sd, 0)
        testthat::expect_equal(id2$median_sd, 0)
        testthat::expect_equal(id2$n_var_sd_lt_1, 2L)
        testthat::expect_equal(id2$max_abs_any, 2)
        testthat::expect_equal(id2$max_abs_variable, "y2")
      }
    )

    testthat::test_that(
      paste(
        text,
        "DiagnosticsByID",
        "temporarily treats missing codes as missing"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(1, 2, 3),
          y1 = c(-999, 1, NA),
          y2 = c(-999, NA, 2),
          stringsAsFactors = FALSE
        )

        out <- DiagnosticsByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          missing_codes = -999,
          min_nonmissing = 2L
        )

        testthat::expect_equal(out$n_rows, 3L)
        testthat::expect_equal(out$n_observed_rows, 0L)
        testthat::expect_equal(out$n_complete_rows, 0L)
        testthat::expect_equal(out$prop_all_missing, 1 / 3)

        testthat::expect_true(is.na(out$max_obs_gap))
        testthat::expect_true(is.na(out$median_obs_gap))
        testthat::expect_true(is.na(out$mean_obs_gap))

        testthat::expect_equal(out$miss_y1, 2 / 3)
        testthat::expect_equal(out$miss_y2, 2 / 3)
        testthat::expect_equal(out$n_y1, 1L)
        testthat::expect_equal(out$n_y2, 1L)
        testthat::expect_true(is.na(out$sd_y1))
        testthat::expect_true(is.na(out$sd_y2))
        testthat::expect_true(is.na(out$min_sd))
        testthat::expect_true(is.na(out$median_sd))
        testthat::expect_equal(out$max_abs_any, 2)
        testthat::expect_equal(out$max_abs_variable, "y2")

        testthat::expect_equal(
          data$y1[1],
          -999
        )
        testthat::expect_equal(
          data$y2[1],
          -999
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DiagnosticsByID",
        "computes POSIX time gaps using the requested unit"
      ),
      {
        testthat::skip_on_cran()

        time_values <- as.POSIXct(
          c(
            "2026-01-01 00:00:00",
            "2026-01-01 01:00:00",
            "2026-01-01 03:00:00"
          ),
          tz = "UTC"
        )

        data <- data.frame(
          id = c(1, 1, 1),
          time = time_values,
          y = c(1, 2, 3),
          stringsAsFactors = FALSE
        )

        out <- DiagnosticsByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          posix_unit = "hours"
        )

        testthat::expect_equal(out$max_obs_gap, 2)
        testthat::expect_equal(out$median_obs_gap, 1.5)
        testthat::expect_equal(out$mean_obs_gap, 1.5)
      }
    )

    testthat::test_that(
      paste(
        text,
        "DiagnosticsByID",
        "checks diagnostic arguments"
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
          DiagnosticsByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            min_nonmissing = 0
          ),
          "`min_nonmissing` must be a positive integer.",
          fixed = TRUE
        )

        testthat::expect_error(
          DiagnosticsByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            min_nonmissing = 2
          ),
          "`min_nonmissing` must be less than or equal to `length(observed)`.",
          fixed = TRUE
        )

        testthat::expect_error(
          DiagnosticsByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            extreme_cut = c(0, 1)
          ),
          "`extreme_cut` must be a positive numeric vector.",
          fixed = TRUE
        )

        testthat::expect_error(
          DiagnosticsByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            sd_cut = -0.01
          ),
          "`sd_cut` must be a non-negative numeric vector.",
          fixed = TRUE
        )

        testthat::expect_error(
          DiagnosticsByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            time_scale = 0
          ),
          "`time_scale` must be a positive number.",
          fixed = TRUE
        )

        testthat::expect_error(
          DiagnosticsByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            posix_unit = "months"
          ),
          "`posix_unit` must be one of 'auto', 'secs', 'mins', 'hours', 'days', or 'weeks'.",
          fixed = TRUE
        )
      }
    )
  },
  text = "test-dynTools-diagnostics-by-id"
)
