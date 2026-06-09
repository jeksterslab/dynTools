## ---- test-dynTools-round-clock-time
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "RoundClockTime",
        "rounds POSIXct values to nearest hour"
      ),
      {
        x <- as.POSIXct(
          c(
            "2020-01-01 10:29:00",
            "2020-01-01 10:31:00",
            "2020-01-01 10:30:00"
          ),
          tz = "America/New_York"
        )

        out <- RoundClockTime(
          x = x,
          unit = "hour",
          method = "round"
        )

        testthat::expect_equal(
          format(
            x = out,
            format = "%Y-%m-%d %H:%M:%S",
            tz = "America/New_York"
          ),
          c(
            "2020-01-01 10:00:00",
            "2020-01-01 11:00:00",
            "2020-01-01 11:00:00"
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "RoundClockTime",
        "floors POSIXct values to hour"
      ),
      {
        x <- as.POSIXct(
          c(
            "2020-01-01 10:00:00",
            "2020-01-01 10:59:59"
          ),
          tz = "UTC"
        )

        out <- RoundClockTime(
          x = x,
          unit = "hour",
          method = "floor"
        )

        testthat::expect_equal(
          format(
            x = out,
            format = "%Y-%m-%d %H:%M:%S",
            tz = "UTC"
          ),
          c(
            "2020-01-01 10:00:00",
            "2020-01-01 10:00:00"
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "RoundClockTime",
        "ceilings POSIXct values to hour"
      ),
      {
        x <- as.POSIXct(
          c(
            "2020-01-01 10:00:00",
            "2020-01-01 10:00:01",
            NA
          ),
          tz = "UTC"
        )

        out <- RoundClockTime(
          x = x,
          unit = "hour",
          method = "ceiling"
        )

        testthat::expect_equal(
          format(
            x = out,
            format = "%Y-%m-%d %H:%M:%S",
            tz = "UTC"
          ),
          c(
            "2020-01-01 10:00:00",
            "2020-01-01 11:00:00",
            NA
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "RoundClockTime",
        "rounds POSIXct values to nearest minute"
      ),
      {
        x <- as.POSIXct(
          c(
            "2020-01-01 10:29:29",
            "2020-01-01 10:29:31",
            "2020-01-01 10:29:30"
          ),
          tz = "UTC"
        )

        out <- RoundClockTime(
          x = x,
          unit = "minute",
          method = "round"
        )

        testthat::expect_equal(
          format(
            x = out,
            format = "%Y-%m-%d %H:%M:%S",
            tz = "UTC"
          ),
          c(
            "2020-01-01 10:29:00",
            "2020-01-01 10:30:00",
            "2020-01-01 10:30:00"
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "RoundClockTime",
        "rounds numeric Unix seconds and returns POSIXct"
      ),
      {
        x <- as.numeric(
          as.POSIXct(
            c(
              "2020-01-01 10:29:00",
              "2020-01-01 10:31:00"
            ),
            tz = "UTC"
          )
        )

        out <- RoundClockTime(
          x = x,
          unit = "hour",
          method = "round",
          tz = "UTC"
        )

        testthat::expect_s3_class(
          out,
          "POSIXct"
        )

        testthat::expect_equal(
          format(
            x = out,
            format = "%Y-%m-%d %H:%M:%S",
            tz = "UTC"
          ),
          c(
            "2020-01-01 10:00:00",
            "2020-01-01 11:00:00"
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "RoundClockTime",
        "floors and ceilings numeric Unix seconds"
      ),
      {
        x <- as.numeric(
          as.POSIXct(
            c(
              "2020-01-01 10:00:00",
              "2020-01-01 10:00:01",
              "2020-01-01 10:59:59"
            ),
            tz = "UTC"
          )
        )

        out_floor <- RoundClockTime(
          x = x,
          unit = "hour",
          method = "floor",
          tz = "UTC"
        )

        out_ceiling <- RoundClockTime(
          x = x,
          unit = "hour",
          method = "ceiling",
          tz = "UTC"
        )

        testthat::expect_equal(
          format(
            x = out_floor,
            format = "%Y-%m-%d %H:%M:%S",
            tz = "UTC"
          ),
          c(
            "2020-01-01 10:00:00",
            "2020-01-01 10:00:00",
            "2020-01-01 10:00:00"
          )
        )

        testthat::expect_equal(
          format(
            x = out_ceiling,
            format = "%Y-%m-%d %H:%M:%S",
            tz = "UTC"
          ),
          c(
            "2020-01-01 10:00:00",
            "2020-01-01 11:00:00",
            "2020-01-01 11:00:00"
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "RoundClockTime",
        "preserves Date values for day unit"
      ),
      {
        x <- as.Date(
          c(
            "2020-01-01",
            "2020-01-02"
          )
        )

        out <- RoundClockTime(
          x = x,
          unit = "day"
        )

        testthat::expect_identical(
          out,
          x
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "RoundClockTime",
        "checks invalid inputs"
      ),
      {
        testthat::expect_error(
          RoundClockTime(
            x = letters,
            unit = "hour"
          ),
          "`x` must be"
        )

        testthat::expect_error(
          RoundClockTime(
            x = Sys.time(),
            unit = "week"
          ),
          "'arg' should be one of"
        )

        testthat::expect_error(
          RoundClockTime(
            x = as.Date("2020-01-01"),
            unit = "hour"
          ),
          "`Date` values"
        )

        testthat::expect_error(
          RoundClockTime(
            x = Sys.time(),
            unit = ""
          ),
          "`unit`"
        )

        testthat::expect_error(
          RoundClockTime(
            x = Sys.time(),
            unit = "hour",
            tz = ""
          ),
          "`tz`"
        )
      }
    )
  },
  text = "test-dynTools-round-clock-time"
)
