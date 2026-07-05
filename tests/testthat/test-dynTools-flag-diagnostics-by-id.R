## ---- test-dynTools-flag-diagnostics-by-id
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
        "FlagDiagnosticsByID",
        "adds rule-based flags, scores, drop candidates, and reasons"
      ),
      {
        testthat::skip_on_cran()

        x <- data.frame(
          id = 1:10,
          n_observed_rows = c(
            40, 20, 40, 40, 40, 40, 40, 20, 40, 40
          ),
          n_complete_rows = c(
            35, 35, 10, 35, 35, 35, 35, 10, 35, 35
          ),
          prop_all_missing = c(
            0.10, 0.10, 0.10, 0.99, 0.10,
            0.10, 0.10, 0.99, 0.10, 0.10
          ),
          max_obs_gap = c(
            2, 2, 2, 2, 10, 2, 2, 10, 2, 2
          ),
          median_obs_gap = c(
            1, 1, 1, 1, 1, 7, 1, 7, 1, 1
          ),
          min_sd = c(
            0.10, 0.10, 0.10, 0.10, 0.10, 0.10, 0.01, 0.01, 0.10, 0.10
          ),
          n_duplicate_id_time = c(
            0, 0, 0, 0, 0, 0, 0, 0, 1, 0
          ),
          n_nonfinite_total = c(
            0, 0, 0, 0, 0, 0, 0, 0, 0, 2
          ),
          n_abs_gt6_total = c(
            0, 0, 0, 0, 0, 0, 1, 1, 0, 0
          ),
          stringsAsFactors = FALSE
        )

        out <- FlagDiagnosticsByID(
          x = x,
          min_observed_rows = 30,
          min_complete_rows = 20,
          max_prop_all_missing = 0.95,
          max_gap = 5,
          max_median_gap = 5,
          min_sd = 0.05,
          extreme_cut = 6,
          drop_score_cut = 2
        )

        testthat::expect_equal(
          out$flag_low_observed_rows,
          c(FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE)
        )

        testthat::expect_equal(
          out$flag_low_complete_rows,
          c(FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE)
        )

        testthat::expect_equal(
          out$flag_mostly_all_missing,
          c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE)
        )

        testthat::expect_equal(
          out$flag_large_gap,
          c(FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE)
        )

        testthat::expect_equal(
          out$flag_large_median_gap,
          c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, FALSE, FALSE)
        )

        testthat::expect_equal(
          out$flag_low_sd,
          c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE)
        )

        testthat::expect_equal(
          out$flag_duplicate_id_time,
          c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE)
        )

        testthat::expect_equal(
          out$flag_nonfinite,
          c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE)
        )

        testthat::expect_equal(
          out$flag_extreme,
          c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE)
        )

        testthat::expect_equal(
          out$priority_score,
          c(0, 1, 1, 1, 1, 1, 2, 7, 1, 1)
        )

        testthat::expect_equal(
          out$flag_any,
          c(FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE)
        )

        testthat::expect_equal(
          out$drop_sensitivity_candidate,
          c(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE)
        )

        testthat::expect_equal(
          out$flag_reason,
          c(
            "",
            "n_obs_lt_30",
            "n_complete_lt_20",
            "prop_all_missing_gt_0.95",
            "max_gap_gt_5",
            "median_gap_gt_5",
            "sd_lt_0.05;extreme_abs_gt_6",
            paste(
              c(
                "n_obs_lt_30",
                "n_complete_lt_20",
                "prop_all_missing_gt_0.95",
                "max_gap_gt_5",
                "median_gap_gt_5",
                "sd_lt_0.05",
                "extreme_abs_gt_6"
              ),
              collapse = ";"
            ),
            "duplicate_id_time",
            "nonfinite_observed"
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "FlagDiagnosticsByID",
        "ignores optional thresholds when they are NULL"
      ),
      {
        testthat::skip_on_cran()

        x <- data.frame(
          id = 1:2,
          n_observed_rows = c(40, 40),
          n_complete_rows = c(0, 0),
          prop_all_missing = c(1, 1),
          max_obs_gap = c(100, 100),
          median_obs_gap = c(100, 100),
          min_sd = c(0.00, 0.00),
          n_duplicate_id_time = c(0, 0),
          n_nonfinite_total = c(0, 0),
          n_abs_gt6_total = c(0, 0),
          stringsAsFactors = FALSE
        )

        out <- FlagDiagnosticsByID(
          x = x,
          min_observed_rows = 30,
          min_complete_rows = NULL,
          max_prop_all_missing = NULL,
          max_gap = NULL,
          max_median_gap = NULL,
          min_sd = NULL,
          extreme_cut = 6
        )

        testthat::expect_equal(
          out$flag_low_complete_rows,
          c(FALSE, FALSE)
        )
        testthat::expect_equal(
          out$flag_mostly_all_missing,
          c(FALSE, FALSE)
        )
        testthat::expect_equal(
          out$flag_large_gap,
          c(FALSE, FALSE)
        )
        testthat::expect_equal(
          out$flag_large_median_gap,
          c(FALSE, FALSE)
        )
        testthat::expect_equal(
          out$flag_low_sd,
          c(FALSE, FALSE)
        )
        testthat::expect_equal(
          out$flag_duplicate_id_time,
          c(FALSE, FALSE)
        )
        testthat::expect_equal(
          out$flag_nonfinite,
          c(FALSE, FALSE)
        )
        testthat::expect_equal(
          out$priority_score,
          c(0, 0)
        )
        testthat::expect_equal(
          out$flag_any,
          c(FALSE, FALSE)
        )
        testthat::expect_equal(
          out$drop_sensitivity_candidate,
          c(FALSE, FALSE)
        )
        testthat::expect_equal(
          out$flag_reason,
          c("", "")
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "FlagDiagnosticsByID",
        "checks required input columns and requested extreme column"
      ),
      {
        testthat::skip_on_cran()

        x <- data.frame(
          id = 1,
          n_observed_rows = 40,
          n_complete_rows = 40,
          prop_all_missing = 0,
          max_obs_gap = 1,
          median_obs_gap = 1,
          min_sd = 0.10,
          n_duplicate_id_time = 0,
          n_nonfinite_total = 0,
          n_abs_gt6_total = 0,
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          FlagDiagnosticsByID(
            x = "not a data frame"
          ),
          "`x` must be a data frame returned by `DiagnosticsByID()`.",
          fixed = TRUE
        )

        testthat::expect_error(
          FlagDiagnosticsByID(
            x = x[, setdiff(names(x), "min_sd"), drop = FALSE]
          ),
          "The following required columns are missing from `x`: min_sd.",
          fixed = TRUE
        )

        testthat::expect_error(
          FlagDiagnosticsByID(
            x = x[
              ,
              setdiff(
                x = names(x),
                y = c("n_duplicate_id_time", "n_nonfinite_total")
              ),
              drop = FALSE
            ]
          ),
          paste(
            "The following required columns are missing from `x`:",
            "n_duplicate_id_time, n_nonfinite_total."
          ),
          fixed = TRUE
        )

        testthat::expect_error(
          FlagDiagnosticsByID(
            x = x,
            extreme_cut = 5
          ),
          "n_abs_gt5_total"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "FlagDiagnosticsByID",
        "checks threshold arguments"
      ),
      {
        testthat::skip_on_cran()

        x <- data.frame(
          id = 1,
          n_observed_rows = 40,
          n_complete_rows = 40,
          prop_all_missing = 0,
          max_obs_gap = 1,
          median_obs_gap = 1,
          min_sd = 0.10,
          n_duplicate_id_time = 0,
          n_nonfinite_total = 0,
          n_abs_gt6_total = 0,
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          FlagDiagnosticsByID(
            x = x,
            min_observed_rows = 0
          ),
          "`min_observed_rows` must be a positive number.",
          fixed = TRUE
        )

        testthat::expect_error(
          FlagDiagnosticsByID(
            x = x,
            min_complete_rows = 0
          ),
          "`min_complete_rows` must be `NULL` or a positive number.",
          fixed = TRUE
        )

        testthat::expect_error(
          FlagDiagnosticsByID(
            x = x,
            max_prop_all_missing = 2
          ),
          "`max_prop_all_missing` must be `NULL` or a number between 0 and 1.",
          fixed = TRUE
        )

        testthat::expect_error(
          FlagDiagnosticsByID(
            x = x,
            max_gap = 0
          ),
          "`max_gap` must be `NULL` or a positive number.",
          fixed = TRUE
        )

        testthat::expect_error(
          FlagDiagnosticsByID(
            x = x,
            max_median_gap = 0
          ),
          "`max_median_gap` must be `NULL` or a positive number.",
          fixed = TRUE
        )

        testthat::expect_error(
          FlagDiagnosticsByID(
            x = x,
            min_sd = -0.01
          ),
          "`min_sd` must be `NULL` or a non-negative number.",
          fixed = TRUE
        )

        testthat::expect_error(
          FlagDiagnosticsByID(
            x = x,
            extreme_cut = 0
          ),
          "`extreme_cut` must be a positive number.",
          fixed = TRUE
        )

        testthat::expect_error(
          FlagDiagnosticsByID(
            x = x,
            drop_score_cut = 0
          ),
          "`drop_score_cut` must be a positive number.",
          fixed = TRUE
        )
      }
    )
  },
  text = "test-dynTools-flag-diagnostics-by-id"
)
