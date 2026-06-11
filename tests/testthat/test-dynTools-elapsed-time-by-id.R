## ---- test-dynTools-elapsed-time-by-id
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "ElapsedTimeByID",
        "creates elapsed POSIXct time by ID"
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

        out <- ElapsedTimeByID(
          data = data,
          id = "id",
          time = "datetime",
          output = "time",
          units = "days"
        )

        testthat::expect_equal(
          out$id,
          c(1, 1, 2, 2)
        )

        testthat::expect_equal(
          out$time,
          c(0, 1.5, 0, 0.5),
          tolerance = 1e-12
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ElapsedTimeByID",
        "converts numeric input units"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 2, 2),
          seconds = c(86400, 172800, 0, 43200),
          stringsAsFactors = FALSE
        )

        out <- ElapsedTimeByID(
          data = data,
          id = "id",
          time = "seconds",
          output = "days",
          units = "days",
          input_units = "secs"
        )

        testthat::expect_equal(
          out$days,
          c(0, 1, 0, 0.5),
          tolerance = 1e-12
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ElapsedTimeByID",
        "supports global origin"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(10, 12, 20, 21),
          stringsAsFactors = FALSE
        )

        out <- ElapsedTimeByID(
          data = data,
          id = "id",
          time = "time",
          output = "elapsed",
          origin = "global"
        )

        testthat::expect_equal(
          out$elapsed,
          c(0, 2, 10, 11)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ElapsedTimeByID",
        "preserves missing times as missing elapsed values"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(1, NA, 3),
          stringsAsFactors = FALSE
        )

        out <- ElapsedTimeByID(
          data = data,
          id = "id",
          time = "time",
          output = "elapsed"
        )

        testthat::expect_equal(
          out$elapsed,
          c(0, 2, NA)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ElapsedTimeByID",
        "checks output name collision and replacement"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1),
          time = c(1, 2),
          elapsed = c(0, 1),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          ElapsedTimeByID(
            data = data,
            id = "id",
            time = "time",
            output = "elapsed"
          ),
          "already exists"
        )

        out <- ElapsedTimeByID(
          data = data,
          id = "id",
          time = "time",
          replace = TRUE
        )

        testthat::expect_equal(
          out$time,
          c(0, 1)
        )
      }
    )
  },
  text = "test-dynTools-elapsed-time-by-id"
)
