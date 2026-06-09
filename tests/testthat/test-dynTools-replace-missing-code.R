## ---- test-dynTools-replace-missing-code
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "ReplaceMissingCode",
        "replaces numeric and character missing codes"
      ),
      {
        data <- data.frame(
          id = 1:4,
          y = c(1, -999, 3, NA),
          x = c("a", "-999", NA, "d"),
          stringsAsFactors = FALSE
        )

        out <- ReplaceMissingCode(
          data = data,
          values = c(-999, "-999")
        )

        testthat::expect_equal(
          out$y,
          c(1, NA, 3, NA)
        )
        testthat::expect_equal(
          out$x,
          c("a", NA, NA, "d")
        )
        testthat::expect_equal(
          out$id,
          1:4
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ReplaceMissingCode",
        "only modifies selected columns"
      ),
      {
        data <- data.frame(
          y = c(1, -999, 3),
          z = c(1, -999, 3),
          stringsAsFactors = FALSE
        )

        out <- ReplaceMissingCode(
          data = data,
          values = -999,
          columns = "y"
        )

        testthat::expect_equal(
          out$y,
          c(1, NA, 3)
        )
        testthat::expect_equal(
          out$z,
          c(1, -999, 3)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ReplaceMissingCode",
        "preserves factor columns"
      ),
      {
        data <- data.frame(
          group = factor(c("a", "-999", "b")),
          stringsAsFactors = FALSE
        )

        out <- ReplaceMissingCode(
          data = data,
          values = "-999"
        )

        testthat::expect_true(
          is.factor(out$group)
        )
        testthat::expect_true(
          is.na(out$group[2])
        )
        testthat::expect_equal(
          as.character(out$group[c(1, 3)]),
          c("a", "b")
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ReplaceMissingCode",
        "handles integer and logical columns"
      ),
      {
        data <- data.frame(
          y = c(1L, -999L, 3L),
          flag = c(TRUE, FALSE, TRUE),
          stringsAsFactors = FALSE
        )

        out <- ReplaceMissingCode(
          data = data,
          values = c(-999, "FALSE")
        )

        testthat::expect_equal(
          out$y,
          c(1L, NA, 3L)
        )
        testthat::expect_equal(
          out$flag,
          c(TRUE, NA, TRUE)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ReplaceMissingCode",
        "returns unchanged data for NULL columns or empty values"
      ),
      {
        data <- data.frame(
          y = c(1, -999, 3),
          stringsAsFactors = FALSE
        )

        testthat::expect_equal(
          ReplaceMissingCode(
            data = data,
            columns = NULL
          ),
          data
        )

        testthat::expect_equal(
          ReplaceMissingCode(
            data = data,
            values = numeric(0)
          ),
          data
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ReplaceMissingCode",
        "validates inputs"
      ),
      {
        testthat::expect_error(
          ReplaceMissingCode(
            data = matrix(1:4, nrow = 2)
          ),
          "`data` must be"
        )

        data <- data.frame(
          y = 1:3,
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          ReplaceMissingCode(
            data = data,
            columns = "z"
          ),
          "not in `data`"
        )

        testthat::expect_error(
          ReplaceMissingCode(
            data = data,
            columns = NA_character_
          ),
          "`columns` must be"
        )
      }
    )
  },
  text = "test-dynTools-replace-missing-code"
)
