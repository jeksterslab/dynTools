## ---- test-dynTools-elapsed-time-by-id-ct
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
        "ElapsedTimeByIDCT",
        "creates mean-scaled CT elapsed time by ID"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(2, 1, 1, 2),
          datetime = as.POSIXct(
            c(
              "2020-01-04 00:00:00",
              "2020-01-01 00:00:00",
              "2020-01-02 12:00:00",
              "2020-01-04 12:00:00"
            ),
            tz = "UTC"
          ),
          y = 1:4
        )

        out <- ElapsedTimeByIDCT(
          data = data,
          id = "id",
          time = "datetime",
          output = "time_ct",
          units = "hours",
          scale = "mean_dt"
        )

        testthat::expect_equal(
          out$id,
          c(1, 1, 2, 2)
        )

        testthat::expect_equal(
          out$time_ct,
          c(0, 1.5, 0, 0.5),
          tolerance = 1e-12
        )

        scale_info <- attr(out, "time_ct_scale")

        testthat::expect_identical(
          scale_info$variable,
          "time_ct"
        )

        testthat::expect_identical(
          scale_info$original_units,
          "hours"
        )

        testthat::expect_identical(
          scale_info$scale,
          "mean_dt"
        )

        testthat::expect_equal(
          scale_info$scale_value,
          24,
          tolerance = 1e-12
        )

        testthat::expect_equal(
          scale_info$mean_dt_original_units,
          24,
          tolerance = 1e-12
        )

        testthat::expect_equal(
          scale_info$median_dt_original_units,
          24,
          tolerance = 1e-12
        )

        testthat::expect_equal(
          scale_info$min_dt_original_units,
          12,
          tolerance = 1e-12
        )

        testthat::expect_equal(
          scale_info$max_dt_original_units,
          36,
          tolerance = 1e-12
        )

        testthat::expect_identical(
          scale_info$n_dt,
          2L
        )

        testthat::expect_identical(
          scale_info$n_positive_dt,
          2L
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ElapsedTimeByIDCT",
        "supports median scaling"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1, 2, 2),
          time = c(0, 2, 12, 0, 2),
          stringsAsFactors = FALSE
        )

        out <- ElapsedTimeByIDCT(
          data = data,
          id = "id",
          time = "time",
          output = "time_ct",
          scale = "median_dt"
        )

        testthat::expect_equal(
          out$time_ct,
          c(0, 1, 6, 0, 1),
          tolerance = 1e-12
        )

        scale_info <- attr(out, "time_ct_scale")

        testthat::expect_equal(
          scale_info$scale_value,
          2,
          tolerance = 1e-12
        )

        testthat::expect_equal(
          scale_info$mean_dt_original_units,
          14 / 3,
          tolerance = 1e-12
        )

        testthat::expect_equal(
          scale_info$median_dt_original_units,
          2,
          tolerance = 1e-12
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ElapsedTimeByIDCT",
        "uses supplied scale_value"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(0, 10, 0, 20),
          stringsAsFactors = FALSE
        )

        out <- ElapsedTimeByIDCT(
          data = data,
          id = "id",
          time = "time",
          output = "time_ct",
          scale_value = 10
        )

        testthat::expect_equal(
          out$time_ct,
          c(0, 1, 0, 2),
          tolerance = 1e-12
        )

        scale_info <- attr(out, "time_ct_scale")

        testthat::expect_equal(
          scale_info$scale_value,
          10,
          tolerance = 1e-12
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ElapsedTimeByIDCT",
        "supports replacing the time variable"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(0, 10, 0, 20),
          stringsAsFactors = FALSE
        )

        out <- ElapsedTimeByIDCT(
          data = data,
          id = "id",
          time = "time",
          scale_value = 10,
          replace = TRUE
        )

        testthat::expect_false(
          "time_ct" %in% names(out)
        )

        testthat::expect_equal(
          out$time,
          c(0, 1, 0, 2),
          tolerance = 1e-12
        )

        testthat::expect_identical(
          attr(out, "time_ct_scale")$variable,
          "time"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ElapsedTimeByIDCT",
        "checks output name collision and invalid scale_value"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1),
          time = c(0, 1),
          time_ct = c(0, 1),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          ElapsedTimeByIDCT(
            data = data,
            id = "id",
            time = "time",
            output = "time_ct"
          ),
          "already exists"
        )

        testthat::expect_error(
          ElapsedTimeByIDCT(
            data = data,
            id = "id",
            time = "time",
            scale_value = 0,
            replace = TRUE
          ),
          "positive finite numeric scalar"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ElapsedTimeByIDCT",
        "errors when no positive consecutive intervals are found"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 2),
          time = c(0, 0),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          ElapsedTimeByIDCT(
            data = data,
            id = "id",
            time = "time",
            output = "time_ct"
          ),
          "No positive consecutive time intervals"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ElapsedTimeByIDCT",
        "returns scaling metadata for empty data"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = integer(0),
          time = numeric(0),
          stringsAsFactors = FALSE
        )

        out <- ElapsedTimeByIDCT(
          data = data,
          id = "id",
          time = "time",
          output = "time_ct"
        )

        testthat::expect_equal(
          nrow(out),
          0L
        )

        testthat::expect_true(
          "time_ct" %in% names(out)
        )

        scale_info <- attr(out, "time_ct_scale")

        testthat::expect_identical(
          scale_info$variable,
          "time_ct"
        )

        testthat::expect_identical(
          scale_info$n_dt,
          0L
        )

        testthat::expect_identical(
          scale_info$n_positive_dt,
          0L
        )
      }
    )
  },
  text = "test-dynTools-elapsed-time-by-id-ct"
)
