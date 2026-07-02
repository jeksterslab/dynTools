## ---- test-dynTools-resolve-close-time-by-id
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
        "ResolveCloseTimeByID",
        "resolves close POSIXct times using max_complete"
      ),
      {
        testthat::skip_on_cran()

        origin <- as.POSIXct(
          "2020-01-01 00:00:00",
          tz = "UTC"
        )

        data <- data.frame(
          id = c(1, 1, 1, 1, 2, 2),
          datetime = origin + c(0, 2, 60, 63, 0, 10) * 60,
          y1 = c(1, 2, 3, 4, 5, 6),
          y2 = c(NA, 2, 3, NA, 5, 6),
          row_label = c(
            "id1_t0",
            "id1_t2",
            "id1_t60",
            "id1_t63",
            "id2_t0",
            "id2_t10"
          ),
          stringsAsFactors = FALSE
        )

        out <- ResolveCloseTimeByID(
          data = data,
          id = "id",
          time = "datetime",
          observed = c("y1", "y2"),
          min_gap = as.difftime(
            5,
            units = "mins"
          ),
          method = "max_complete"
        )

        testthat::expect_equal(
          nrow(out),
          4L
        )

        testthat::expect_equal(
          out$row_label,
          c(
            "id1_t2",
            "id1_t60",
            "id2_t0",
            "id2_t10"
          )
        )

        testthat::expect_equal(
          out$id,
          c(1, 1, 2, 2)
        )

        testthat::expect_equal(
          as.numeric(
            difftime(
              time1 = out$datetime,
              time2 = origin,
              units = "mins"
            )
          ),
          c(2, 60, 0, 10)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ResolveCloseTimeByID",
        "uses first and last rows within numeric close-time clusters"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1, 1, 2, 2),
          time = c(0, 0.5, 1.0, 3.0, 0, 2),
          y = c(1, 2, 3, 4, 5, 6),
          row_label = c(
            "id1_t0",
            "id1_t0.5",
            "id1_t1",
            "id1_t3",
            "id2_t0",
            "id2_t2"
          ),
          stringsAsFactors = FALSE
        )

        out_first <- ResolveCloseTimeByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          min_gap = 1,
          method = "first"
        )

        testthat::expect_equal(
          out_first$row_label,
          c(
            "id1_t0",
            "id1_t3",
            "id2_t0",
            "id2_t2"
          )
        )

        out_last <- ResolveCloseTimeByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          min_gap = 1,
          method = "last"
        )

        testthat::expect_equal(
          out_last$row_label,
          c(
            "id1_t1",
            "id1_t3",
            "id2_t0",
            "id2_t2"
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ResolveCloseTimeByID",
        "starts a new cluster when gap equals min_gap"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(0, 5, 9),
          y = c(1, 2, 3),
          stringsAsFactors = FALSE
        )

        out <- ResolveCloseTimeByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          min_gap = 5,
          method = "first"
        )

        testthat::expect_equal(
          out$time,
          c(0, 5)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ResolveCloseTimeByID",
        "uses deterministic tie-breaking for max_complete"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(0, 1, 2),
          y1 = c(1, 2, 3),
          y2 = c(NA, NA, NA),
          row_label = c(
            "first",
            "second",
            "third"
          ),
          stringsAsFactors = FALSE
        )

        out <- ResolveCloseTimeByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_gap = 5,
          method = "max_complete"
        )

        testthat::expect_equal(
          nrow(out),
          1L
        )

        testthat::expect_equal(
          out$row_label,
          "first"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ResolveCloseTimeByID",
        "returns empty data unchanged"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = integer(0),
          time = numeric(0),
          y = numeric(0),
          stringsAsFactors = FALSE
        )

        out <- ResolveCloseTimeByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          min_gap = 1,
          method = "max_complete"
        )

        testthat::expect_equal(
          nrow(out),
          0L
        )

        testthat::expect_equal(
          names(out),
          names(data)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ResolveCloseTimeByID",
        "rejects malformed input arguments"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 2),
          time = c(0, 1, 0),
          y = c(1, 2, 3),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = as.matrix(data),
            id = "id",
            time = "time",
            observed = "y",
            min_gap = 1
          ),
          "`data` must be a data frame"
        )

        data_duplicate_names <- data
        names(data_duplicate_names) <- c(
          "id",
          "id",
          "y"
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data_duplicate_names,
            id = "id",
            time = "time",
            observed = "y",
            min_gap = 1
          ),
          "`data` must have unique column names"
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data,
            id = c("id", "id2"),
            time = "time",
            observed = "y",
            min_gap = 1
          ),
          "`id` must be a non-empty character string"
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data,
            id = "id",
            time = c("time", "time2"),
            observed = "y",
            min_gap = 1
          ),
          "`time` must be a non-empty character string"
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data,
            id = "id",
            time = "time",
            observed = character(0),
            min_gap = 1
          ),
          "`observed` must be a non-empty character vector"
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            min_gap = 1,
            method = "middle"
          ),
          "should be one of"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ResolveCloseTimeByID",
        "rejects missing variables and missing IDs or times"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 2),
          time = c(0, 1, 0),
          y = c(1, 2, 3),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data,
            id = "missing_id",
            time = "time",
            observed = "y",
            min_gap = 1
          ),
          "not in `data`"
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data,
            id = "id",
            time = "missing_time",
            observed = "y",
            min_gap = 1
          ),
          "not in `data`"
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data,
            id = "id",
            time = "time",
            observed = "missing_y",
            min_gap = 1
          ),
          "not in `data`"
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data.frame(
              id = c(1, NA, 2),
              time = c(0, 1, 0),
              y = c(1, 2, 3),
              stringsAsFactors = FALSE
            ),
            id = "id",
            time = "time",
            observed = "y",
            min_gap = 1
          ),
          "`id` must not contain missing values"
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data.frame(
              id = c(1, 1, 2),
              time = c(0, NA, 0),
              y = c(1, 2, 3),
              stringsAsFactors = FALSE
            ),
            id = "id",
            time = "time",
            observed = "y",
            min_gap = 1
          ),
          "`time` must not contain missing values"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ResolveCloseTimeByID",
        "rejects invalid time and min_gap specifications"
      ),
      {
        testthat::skip_on_cran()

        data_numeric <- data.frame(
          id = c(1, 1, 2),
          time = c(0, 1, 0),
          y = c(1, 2, 3),
          stringsAsFactors = FALSE
        )

        data_character_time <- data.frame(
          id = c(1, 1, 2),
          time = c("a", "b", "c"),
          y = c(1, 2, 3),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data_character_time,
            id = "id",
            time = "time",
            observed = "y",
            min_gap = 1
          ),
          "`time` must be numeric, Date, or POSIXt"
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data_numeric,
            id = "id",
            time = "time",
            observed = "y",
            min_gap = 0
          ),
          paste(
            "`min_gap` must be a positive finite numeric scalar",
            "when `time` is numeric"
          )
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data_numeric,
            id = "id",
            time = "time",
            observed = "y",
            min_gap = NA_real_
          ),
          paste(
            "`min_gap` must be a positive finite numeric scalar",
            "when `time` is numeric"
          )
        )

        origin <- as.POSIXct(
          "2020-01-01 00:00:00",
          tz = "UTC"
        )

        data_datetime <- data.frame(
          id = c(1, 1, 2),
          datetime = origin + c(0, 60, 0),
          y = c(1, 2, 3),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data_datetime,
            id = "id",
            time = "datetime",
            observed = "y",
            min_gap = 5
          ),
          "`min_gap` must be a `difftime` object when `time` is Date or POSIXt"
        )

        testthat::expect_error(
          ResolveCloseTimeByID(
            data = data_datetime,
            id = "id",
            time = "datetime",
            observed = "y",
            min_gap = as.difftime(
              0,
              units = "mins"
            )
          ),
          "`min_gap` must be positive"
        )
      }
    )
  },
  text = "test-dynTools-resolve-close-time-by-id"
)
