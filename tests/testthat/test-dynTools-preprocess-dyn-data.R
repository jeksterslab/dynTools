## ---- test-dynTools-preprocess-dyn-data
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
        "performs the core numeric-time preprocessing workflow"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 1, 1, 2, 2, 2),
          t = c(0, 0, 1, 2, 0, 1, 2),
          y1 = c(NA, 1, 2, 3, NA, 5, 6),
          y2 = c(NA, 1, -999, 4, NA, -999, 7),
          z = c(10, 11, 12, 13, 20, 21, 22)
        )

        out <- PreprocessDynData(
          data = data,
          id = "id",
          time = "t",
          observed = c("y1", "y2"),
          covariates = "z",
          screen = FALSE,
          detrend = FALSE,
          center = FALSE,
          final_diagnostics = FALSE
        )

        testthat::expect_s3_class(
          out,
          "dynToolsPreprocessDynData"
        )
        testthat::expect_s3_class(
          out$data,
          "data.frame"
        )
        testthat::expect_null(out$diagnostics)
        testthat::expect_null(out$final_diagnostics)
        testthat::expect_null(out$drop_id)
        testthat::expect_null(out$flagged_id)

        expected <- data.frame(
          id = c(1, 1, 1, 2, 2),
          time = c(0, 1, 2, 0, 1),
          y1 = c(1, 2, 3, 5, 6),
          y2 = c(1, NA, 4, NA, 7),
          z = c(11, 12, 13, 21, 22)
        )

        testthat::expect_equal(
          out$data,
          expected
        )
        testthat::expect_equal(
          rownames(out$data),
          as.character(seq_len(nrow(out$data)))
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "can return only the processed data frame"
      ),
      {
        data <- data.frame(
          id = rep(1:2, each = 3),
          t = rep(0:2, times = 2),
          y = c(1, 2, 3, 10, 12, 14)
        )

        out <- PreprocessDynData(
          data = data,
          id = "id",
          time = "t",
          observed = "y",
          screen = FALSE,
          detrend = FALSE,
          center = TRUE,
          scale = FALSE,
          final_diagnostics = FALSE,
          return_list = FALSE
        )

        expected <- data.frame(
          id = rep(1:2, each = 3),
          time = rep(0:2, times = 2),
          y = c(-1, 0, 1, -2, 0, 2)
        )

        testthat::expect_s3_class(
          out,
          "data.frame"
        )
        testthat::expect_equal(
          out,
          expected
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "constructs elapsed time from date and clock-time variables"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 1),
          date = rep("2020-01-01", 3),
          clock = c("08:00", "10:00", "12:00"),
          y = c(1, 2, 3)
        )

        out <- PreprocessDynData(
          data = data,
          id = "id",
          date = "date",
          clock_time = "clock",
          observed = "y",
          elapsed_units = "hours",
          screen = FALSE,
          detrend = FALSE,
          center = FALSE,
          final_diagnostics = FALSE
        )

        expected <- data.frame(
          id = c(1, 1, 1),
          time = c(0, 2, 4),
          y = c(1, 2, 3)
        )

        testthat::expect_equal(
          out$data,
          expected
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "drops manual IDs"
      ),
      {
        data <- data.frame(
          id = rep(1:3, each = 2),
          t = rep(c(0, 1), times = 3),
          y = 1:6
        )

        out <- PreprocessDynData(
          data = data,
          id = "id",
          time = "t",
          observed = "y",
          drop_id = 2,
          screen = FALSE,
          detrend = FALSE,
          center = FALSE,
          final_diagnostics = FALSE
        )

        testthat::expect_equal(
          unique(out$data$id),
          c(1, 3)
        )
        testthat::expect_equal(
          out$drop_id,
          2
        )
        testthat::expect_equal(
          out$manual_drop_id,
          2
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "flags IDs without dropping them by default"
      ),
      {
        data <- data.frame(
          id = rep(1:2, each = 3),
          t = rep(0:2, times = 2),
          y = c(1, 2, 3, 5, 5, 5)
        )

        out <- PreprocessDynData(
          data = data,
          id = "id",
          time = "t",
          observed = "y",
          screen = TRUE,
          drop_flagged = FALSE,
          min_observed_rows = 1,
          min_sd = 0.05,
          drop_score_cut = 1,
          detrend = FALSE,
          center = FALSE,
          final_diagnostics = FALSE
        )

        testthat::expect_equal(
          out$flagged_id,
          2
        )
        testthat::expect_null(
          out$drop_id
        )
        testthat::expect_equal(
          unique(out$data$id),
          c(1, 2)
        )
        testthat::expect_true(
          all(
            c(
              "flag_low_sd",
              "drop_sensitivity_candidate"
            ) %in% names(out$diagnostics)
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "drops flagged IDs when requested"
      ),
      {
        data <- data.frame(
          id = rep(1:2, each = 3),
          t = rep(0:2, times = 2),
          y = c(1, 2, 3, 5, 5, 5)
        )

        out <- PreprocessDynData(
          data = data,
          id = "id",
          time = "t",
          observed = "y",
          screen = TRUE,
          drop_flagged = TRUE,
          min_observed_rows = 1,
          min_sd = 0.05,
          drop_score_cut = 1,
          detrend = FALSE,
          center = FALSE,
          final_diagnostics = FALSE
        )

        testthat::expect_equal(
          out$flagged_id,
          2
        )
        testthat::expect_equal(
          out$drop_id,
          2
        )
        testthat::expect_equal(
          unique(out$data$id),
          1
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "drops rows with missing time before duplicate resolution"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 1),
          t = c(NA, 0, 1),
          y = c(100, 1, 2)
        )

        out <- PreprocessDynData(
          data = data,
          id = "id",
          time = "t",
          observed = "y",
          drop_missing_time = TRUE,
          screen = FALSE,
          detrend = FALSE,
          center = FALSE,
          final_diagnostics = FALSE
        )

        expected <- data.frame(
          id = c(1, 1),
          time = c(0, 1),
          y = c(1, 2)
        )

        testthat::expect_equal(
          out$data,
          expected
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "checks input arguments"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 2, 2),
          t = c(0, 1, 0, 1),
          y = c(1, 2, 3, 4)
        )

        data_duplicate_names <- data
        names(data_duplicate_names) <- c("id", "id", "y")

        testthat::expect_error(
          PreprocessDynData(
            data = as.matrix(data),
            id = "id",
            time = "t",
            observed = "y"
          ),
          "`data` must be a data frame.",
          fixed = TRUE
        )

        testthat::expect_error(
          PreprocessDynData(
            data = data_duplicate_names,
            id = "id",
            time = "t",
            observed = "y"
          ),
          "`data` must have unique column names.",
          fixed = TRUE
        )

        testthat::expect_error(
          PreprocessDynData(
            data = data,
            id = character(0),
            time = "t",
            observed = "y"
          ),
          "`id` must be a non-empty character string.",
          fixed = TRUE
        )

        testthat::expect_error(
          PreprocessDynData(
            data = data,
            id = "id",
            time = "t",
            observed = character(0)
          ),
          "`observed` must be a non-empty character vector.",
          fixed = TRUE
        )

        testthat::expect_error(
          PreprocessDynData(
            data = data,
            id = "id",
            time = "t",
            observed = "y",
            covariates = NA_character_
          ),
          "`covariates` must be `NULL` or a character vector.",
          fixed = TRUE
        )

        testthat::expect_error(
          PreprocessDynData(
            data = data,
            id = "id",
            observed = "y"
          ),
          paste(
            "Supply either `date` and `clock_time`",
            "or an existing `time` variable."
          ),
          fixed = TRUE
        )

        testthat::expect_error(
          PreprocessDynData(
            data = data,
            id = "id",
            time = "t",
            observed = "y2"
          ),
          "The following variables are missing from `data`: y2.",
          fixed = TRUE
        )

        testthat::expect_error(
          PreprocessDynData(
            data = data,
            id = "id",
            date = "date",
            observed = "y"
          ),
          "`date` and `clock_time` must both be non-empty character strings.",
          fixed = TRUE
        )

        testthat::expect_error(
          PreprocessDynData(
            data = data,
            id = "id",
            time = "t",
            observed = "y",
            regularize = TRUE
          ),
          paste(
            "`delta_t` must be a positive finite number",
            "when `regularize = TRUE`."
          ),
          fixed = TRUE
        )

        testthat::expect_error(
          PreprocessDynData(
            data = data,
            id = "id",
            time = "t",
            observed = "y",
            screen = NA
          ),
          "The following arguments must be `TRUE` or `FALSE`: screen.",
          fixed = TRUE
        )
      }
    )
  },
  text = "test-dynTools-preprocess-dyn-data"
)
