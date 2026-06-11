## ---- test-dynTools-make-clock-time
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "MakeClockTime",
        "combines supported date formats with decimal-hour times"
      ),
      {
        testthat::skip_on_cran()

        out <- MakeClockTime(
          date = c(
            "01/02/20",
            "01/03/2020",
            "2020-01-04"
          ),
          time = c(
            1.5,
            13.25,
            0
          ),
          tz = "America/New_York"
        )

        testthat::expect_s3_class(
          out,
          "POSIXct"
        )

        testthat::expect_equal(
          format(
            x = out,
            format = "%Y-%m-%d %H:%M:%S",
            tz = "America/New_York"
          ),
          c(
            "2020-01-02 01:30:00",
            "2020-01-03 13:15:00",
            "2020-01-04 00:00:00"
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "MakeClockTime",
        "parses character clock times"
      ),
      {
        testthat::skip_on_cran()

        out <- MakeClockTime(
          date = "2020-01-02",
          time = c(
            "01:30",
            "13:15:30",
            "0"
          ),
          tz = "UTC"
        )

        testthat::expect_equal(
          format(
            x = out,
            format = "%Y-%m-%d %H:%M:%S",
            tz = "UTC"
          ),
          c(
            "2020-01-02 01:30:00",
            "2020-01-02 13:15:30",
            "2020-01-02 00:00:00"
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "MakeClockTime",
        "preserves missing and invalid inputs as missing by default"
      ),
      {
        testthat::skip_on_cran()

        out <- MakeClockTime(
          date = c(
            "2020-01-02",
            NA,
            "not-a-date",
            "2020-01-02",
            "2020-01-02"
          ),
          time = c(
            1,
            2,
            3,
            "bad-time",
            "25:00"
          ),
          tz = "UTC"
        )

        testthat::expect_false(
          is.na(out[1])
        )

        testthat::expect_true(
          all(
            is.na(out[-1])
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "MakeClockTime",
        "can error on invalid clock times"
      ),
      {
        testthat::skip_on_cran()

        testthat::expect_error(
          MakeClockTime(
            date = "2020-01-02",
            time = "25:00",
            invalid = "error"
          ),
          "invalid clock time"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "MakeClockTime",
        "allows length-one recycling"
      ),
      {
        testthat::skip_on_cran()

        out <- MakeClockTime(
          date = "2020-01-02",
          time = c(
            0,
            1,
            2
          ),
          tz = "UTC"
        )

        testthat::expect_equal(
          format(
            x = out,
            format = "%Y-%m-%d %H:%M:%S",
            tz = "UTC"
          ),
          c(
            "2020-01-02 00:00:00",
            "2020-01-02 01:00:00",
            "2020-01-02 02:00:00"
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "MakeClockTime",
        "checks incompatible lengths and argument values"
      ),
      {
        testthat::skip_on_cran()

        testthat::expect_error(
          MakeClockTime(
            date = c(
              "2020-01-01",
              "2020-01-02"
            ),
            time = c(
              1,
              2,
              3
            )
          ),
          "same length"
        )

        testthat::expect_error(
          MakeClockTime(
            date = "2020-01-02",
            time = 1,
            tz = ""
          ),
          "`tz`"
        )

        testthat::expect_error(
          MakeClockTime(
            date = "2020-01-02",
            time = 1,
            date_formats = character(0)
          ),
          "`date_formats`"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "MakeClockTime",
        "preserves requested time zone"
      ),
      {
        testthat::skip_on_cran()

        out <- MakeClockTime(
          date = "2020-01-02",
          time = 12,
          tz = "America/New_York"
        )

        testthat::expect_identical(
          attr(out, "tzone"),
          "America/New_York"
        )

        testthat::expect_equal(
          format(
            x = out,
            format = "%Y-%m-%d %H:%M:%S %Z",
            tz = "America/New_York"
          ),
          "2020-01-02 12:00:00 EST"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "MakeClockTime",
        "handles Date and POSIXt date inputs"
      ),
      {
        testthat::skip_on_cran()

        out_date <- MakeClockTime(
          date = as.Date("2020-01-02"),
          time = 6,
          tz = "UTC"
        )

        out_posix <- MakeClockTime(
          date = as.POSIXct(
            x = "2020-01-02 18:45:00",
            tz = "UTC"
          ),
          time = 6,
          tz = "UTC"
        )

        testthat::expect_equal(
          format(
            x = out_date,
            format = "%Y-%m-%d %H:%M:%S",
            tz = "UTC"
          ),
          "2020-01-02 06:00:00"
        )

        testthat::expect_equal(
          format(
            x = out_posix,
            format = "%Y-%m-%d %H:%M:%S",
            tz = "UTC"
          ),
          "2020-01-02 06:00:00"
        )
      }
    )
  },
  text = "test-dynTools-make-clock-time"
)
