## ---- test-dynTools-screen-by-id
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
        "returns diagnostics, drop IDs, and keep IDs"
      ),
      {
        data <- data.frame(
          id = rep(1:2, each = 4),
          time = rep(0:3, times = 2),
          y1 = c(1, 2, 3, 4, 2, 3, 4, 5),
          y2 = c(10, 11, 12, 13, 20, 21, 22, 23)
        )

        out <- ScreenByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_observed_rows = 3,
          min_complete_rows = 3,
          max_prop_all_missing = 0.95,
          max_gap = 2,
          max_median_gap = 2,
          min_sd = 0.05,
          flag_extreme_cut = 100,
          drop_score_cut = 2
        )

        testthat::expect_s3_class(
          out,
          "dynToolsScreenByID"
        )
        testthat::expect_s3_class(
          out$diagnostics,
          "data.frame"
        )
        testthat::expect_equal(
          out$drop_id,
          numeric(0)
        )
        testthat::expect_equal(
          out$keep_id,
          c(1, 2)
        )
        testthat::expect_true(
          all(
            c(
              "id",
              "n_rows",
              "n_observed_rows",
              "n_complete_rows",
              "prop_all_missing",
              "max_obs_gap",
              "median_obs_gap",
              "min_sd",
              "flag_duplicate_id_time",
              "flag_nonfinite",
              "flag_any",
              "drop_sensitivity_candidate",
              "priority_score",
              "flag_reason"
            ) %in% names(out$diagnostics)
          )
        )
        testthat::expect_true(
          all(!out$diagnostics$flag_any)
        )
        testthat::expect_equal(
          out$diagnostics$n_observed_rows,
          c(4L, 4L)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "returns sensitivity-drop candidates by default"
      ),
      {
        data <- data.frame(
          id = rep(1:3, each = 4),
          time = rep(0:3, times = 3),
          y1 = c(
            1, 2, 3, 4,
            5, 5, 5, 5,
            1, 2, 10, 3
          ),
          y2 = c(
            1, 2, 3, 4,
            1, 2, 3, 4,
            1, 2, 3, 4
          )
        )

        out <- ScreenByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_observed_rows = 4,
          min_complete_rows = 4,
          min_sd = 0.05,
          flag_extreme_cut = 6,
          drop_score_cut = 2,
          flagged_only = TRUE
        )

        diagnostics <- out$diagnostics

        testthat::expect_equal(
          out$drop_id,
          2
        )
        testthat::expect_equal(
          out$keep_id,
          c(1, 3)
        )
        testthat::expect_true(
          diagnostics$flag_low_sd[diagnostics$id == 2]
        )
        testthat::expect_true(
          diagnostics$drop_sensitivity_candidate[diagnostics$id == 2]
        )
        testthat::expect_true(
          diagnostics$flag_extreme[diagnostics$id == 3]
        )
        testthat::expect_false(
          diagnostics$drop_sensitivity_candidate[diagnostics$id == 3]
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "can return all flagged IDs"
      ),
      {
        data <- data.frame(
          id = rep(1:3, each = 4),
          time = rep(0:3, times = 3),
          y1 = c(
            1, 2, 3, 4,
            5, 5, 5, 5,
            1, 2, 10, 3
          ),
          y2 = c(
            1, 2, 3, 4,
            1, 2, 3, 4,
            1, 2, 3, 4
          )
        )

        out <- ScreenByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_observed_rows = 4,
          min_complete_rows = 4,
          min_sd = 0.05,
          flag_extreme_cut = 6,
          drop_score_cut = 2,
          flagged_only = FALSE
        )

        testthat::expect_equal(
          out$drop_id,
          c(2, 3)
        )
        testthat::expect_equal(
          out$keep_id,
          1
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "flags low observed rows and low complete rows"
      ),
      {
        data <- data.frame(
          id = rep(1:2, each = 4),
          time = rep(0:3, times = 2),
          y1 = c(1, 2, 3, 4, 1, NA, NA, NA),
          y2 = c(1, 2, 3, 4, 1, NA, 2, NA)
        )

        out <- ScreenByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_nonmissing = 1,
          min_observed_rows = 3,
          min_complete_rows = 3,
          min_sd = 0,
          flag_extreme_cut = 100,
          drop_score_cut = 2
        )

        diagnostics <- out$diagnostics

        testthat::expect_equal(
          out$drop_id,
          2
        )
        testthat::expect_true(
          diagnostics$flag_low_observed_rows[diagnostics$id == 2]
        )
        testthat::expect_true(
          diagnostics$flag_low_complete_rows[diagnostics$id == 2]
        )
        testthat::expect_equal(
          diagnostics$n_observed_rows[diagnostics$id == 2],
          2L
        )
        testthat::expect_equal(
          diagnostics$n_complete_rows[diagnostics$id == 2],
          1L
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "flags mostly all-missing rows"
      ),
      {
        data <- data.frame(
          id = rep(1:2, each = 5),
          time = rep(0:4, times = 2),
          y1 = c(1, 2, 3, 4, 5, 1, NA, NA, NA, NA),
          y2 = c(1, 2, 3, 4, 5, 2, NA, NA, NA, NA)
        )

        out <- ScreenByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_observed_rows = 1,
          max_prop_all_missing = 0.50,
          min_sd = 0,
          flag_extreme_cut = 100,
          drop_score_cut = 2,
          flagged_only = FALSE
        )

        diagnostics <- out$diagnostics

        testthat::expect_equal(
          out$drop_id,
          2
        )
        testthat::expect_true(
          diagnostics$flag_mostly_all_missing[diagnostics$id == 2]
        )
        testthat::expect_equal(
          diagnostics$prop_all_missing[diagnostics$id == 2],
          0.80
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "flags large observed-time gaps"
      ),
      {
        data <- data.frame(
          id = rep(1:2, each = 4),
          time = c(0, 1, 2, 3, 0, 1, 10, 11),
          y1 = c(1, 2, 3, 4, 1, 2, 3, 4),
          y2 = c(4, 5, 6, 7, 4, 5, 6, 7)
        )

        out <- ScreenByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_observed_rows = 4,
          max_gap = 5,
          max_median_gap = 5,
          min_sd = 0,
          flag_extreme_cut = 100,
          drop_score_cut = 2,
          flagged_only = FALSE
        )

        diagnostics <- out$diagnostics

        testthat::expect_equal(
          out$drop_id,
          2
        )
        testthat::expect_true(
          diagnostics$flag_large_gap[diagnostics$id == 2]
        )
        testthat::expect_false(
          diagnostics$flag_large_median_gap[diagnostics$id == 2]
        )
        testthat::expect_equal(
          diagnostics$max_obs_gap[diagnostics$id == 2],
          9
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "applies missing codes before screening"
      ),
      {
        data <- data.frame(
          id = rep(1:2, each = 4),
          time = rep(0:3, times = 2),
          y1 = c(1, 2, 3, 4, 1, -999, -999, -999),
          y2 = c(1, 2, 3, 4, 2, -999, -999, -999)
        )

        out <- ScreenByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          missing_codes = -999,
          min_observed_rows = 2,
          min_complete_rows = 2,
          min_sd = 0,
          flag_extreme_cut = 100,
          drop_score_cut = 1
        )

        diagnostics <- out$diagnostics

        testthat::expect_equal(
          out$drop_id,
          2
        )
        testthat::expect_equal(
          diagnostics$n_observed_rows[diagnostics$id == 2],
          1L
        )
        testthat::expect_equal(
          diagnostics$n_complete_rows[diagnostics$id == 2],
          1L
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "handles character IDs"
      ),
      {
        data <- data.frame(
          id = rep(c("a", "b", "c"), each = 3),
          time = rep(0:2, times = 3),
          y1 = c(1, 2, 3, 4, 4, 4, 1, 2, 9),
          y2 = c(1, 2, 3, 1, 2, 3, 1, 2, 3)
        )

        out <- ScreenByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_observed_rows = 3,
          min_sd = 0.05,
          flag_extreme_cut = 6,
          drop_score_cut = 2,
          flagged_only = FALSE
        )

        testthat::expect_equal(
          out$drop_id,
          c("b", "c")
        )
        testthat::expect_equal(
          out$keep_id,
          "a"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "uses numeric time scale for gap diagnostics"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 1),
          time = c(0, 0.5, 1),
          y = c(1, 2, 3)
        )

        out <- ScreenByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          time_scale = 24,
          min_observed_rows = 3,
          min_sd = 0,
          max_gap = 10,
          flag_extreme_cut = 100,
          flagged_only = FALSE
        )

        testthat::expect_equal(
          out$diagnostics$max_obs_gap,
          12
        )
        testthat::expect_true(
          out$diagnostics$flag_large_gap
        )
        testthat::expect_equal(
          out$drop_id,
          1
        )
      }
    )


    testthat::test_that(
      paste(
        text,
        "allows min_sd to be NULL"
      ),
      {
        data <- data.frame(
          id = rep(1:2, each = 4),
          time = rep(0:3, times = 2),
          y1 = c(1, 2, 3, 4, 5, 5, 5, 5),
          y2 = c(1, 2, 3, 4, 1, 2, 3, 4)
        )

        out <- ScreenByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_observed_rows = 4,
          min_complete_rows = 4,
          min_sd = NULL,
          flag_extreme_cut = 100,
          drop_score_cut = 2,
          flagged_only = FALSE
        )

        diagnostics <- out$diagnostics

        testthat::expect_equal(
          out$drop_id,
          numeric(0)
        )
        testthat::expect_false(
          any(diagnostics$flag_low_sd)
        )
        testthat::expect_false(
          any(diagnostics$flag_any)
        )
      }
    )


    testthat::test_that(
      paste(
        text,
        "flags duplicate ID-time rows and non-finite observed values"
      ),
      {
        data <- data.frame(
          id = c(
            1, 1, 1, 1,
            2, 2, 2, 2,
            3, 3, 3, 3
          ),
          time = c(
            0, 1, 2, 3,
            0, 1, 1, 2,
            0, 1, 2, 3
          ),
          y = c(
            1, 2, 3, 4,
            1, 2, 3, 4,
            1, Inf, NaN, 4
          )
        )

        out <- ScreenByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          min_observed_rows = 1,
          min_complete_rows = NULL,
          max_prop_all_missing = NULL,
          max_gap = NULL,
          max_median_gap = NULL,
          min_sd = 0,
          flag_extreme_cut = 100,
          drop_score_cut = 2,
          flagged_only = FALSE
        )

        diagnostics <- out$diagnostics

        testthat::expect_equal(
          out$drop_id,
          c(2, 3)
        )
        testthat::expect_equal(
          out$keep_id,
          1
        )
        testthat::expect_true(
          diagnostics$flag_duplicate_id_time[diagnostics$id == 2]
        )
        testthat::expect_false(
          diagnostics$flag_nonfinite[diagnostics$id == 2]
        )
        testthat::expect_false(
          diagnostics$flag_duplicate_id_time[diagnostics$id == 3]
        )
        testthat::expect_true(
          diagnostics$flag_nonfinite[diagnostics$id == 3]
        )
        testthat::expect_equal(
          diagnostics$flag_reason[diagnostics$id == 2],
          "duplicate_id_time"
        )
        testthat::expect_equal(
          diagnostics$flag_reason[diagnostics$id == 3],
          "nonfinite_observed"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "checks ScreenByID-specific input arguments"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(0, 1, 0, 1),
          y = c(1, 2, 3, 4)
        )

        testthat::expect_error(
          ScreenByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            flag_extreme_cut = 0
          ),
          "`flag_extreme_cut` must be a positive number.",
          fixed = TRUE
        )

        testthat::expect_error(
          ScreenByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            flag_extreme_cut = NA_real_
          ),
          "`flag_extreme_cut` must be a positive number.",
          fixed = TRUE
        )

        testthat::expect_error(
          ScreenByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            flagged_only = NA
          ),
          "`flagged_only` must be `TRUE` or `FALSE`.",
          fixed = TRUE
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "checks delegated input arguments"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(0, 1, 0, 1),
          y = c(1, 2, 3, 4)
        )

        testthat::expect_error(
          ScreenByID(
            data = as.matrix(data),
            id = "id",
            time = "time",
            observed = "y"
          ),
          "`data` must be a data frame.",
          fixed = TRUE
        )

        testthat::expect_error(
          ScreenByID(
            data = data,
            id = "id",
            time = "time",
            observed = character(0)
          ),
          "`observed` must be a non-empty character vector.",
          fixed = TRUE
        )

        testthat::expect_error(
          ScreenByID(
            data = data,
            id = "id",
            time = "time",
            observed = "z"
          ),
          "The following variables are missing from `data`: z.",
          fixed = TRUE
        )

        testthat::expect_error(
          ScreenByID(
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
          ScreenByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            min_observed_rows = 0
          ),
          "`min_observed_rows` must be a positive number.",
          fixed = TRUE
        )

        testthat::expect_error(
          ScreenByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            max_gap = -1
          ),
          "`max_gap` must be `NULL` or a positive number.",
          fixed = TRUE
        )

        testthat::expect_error(
          ScreenByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            drop_score_cut = 0
          ),
          "`drop_score_cut` must be a positive number.",
          fixed = TRUE
        )
      }
    )
  },
  text = "test-dynTools-screen-by-id"
)
