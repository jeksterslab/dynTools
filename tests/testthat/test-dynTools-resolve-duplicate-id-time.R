## ---- test-dynTools-resolve-duplicate-id-time
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "ResolveDuplicateIDTime",
        "keeps the most complete observed row"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1, 2, 2),
          time = c(0, 0, 1, 0, 0),
          y1 = c(NA, 1, 2, NA, 3),
          y2 = c(NA, 1, 3, 4, 5),
          note = c("drop", "keep", "single", "drop", "keep"),
          stringsAsFactors = FALSE
        )

        out <- ResolveDuplicateIDTime(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          method = "max_complete"
        )

        expected <- data.frame(
          id = c(1, 1, 2),
          time = c(0, 1, 0),
          y1 = c(1, 2, 3),
          y2 = c(1, 3, 5),
          note = c("keep", "single", "keep"),
          stringsAsFactors = FALSE
        )

        testthat::expect_equal(
          out,
          expected
        )

        key <- paste(
          out$id,
          out$time,
          sep = "\r"
        )

        testthat::expect_false(
          anyDuplicated(key) > 0L
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ResolveDuplicateIDTime",
        "supports first and last methods"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(0, 0, 0),
          y = c("a", "b", "c"),
          stringsAsFactors = FALSE
        )

        out_first <- ResolveDuplicateIDTime(
          data = data,
          id = "id",
          time = "time",
          method = "first"
        )

        out_last <- ResolveDuplicateIDTime(
          data = data,
          id = "id",
          time = "time",
          method = "last"
        )

        testthat::expect_identical(
          out_first$y,
          "a"
        )

        testthat::expect_identical(
          out_last$y,
          "c"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ResolveDuplicateIDTime",
        "uses order_by to break ties"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(0, 0, 0),
          y = c(1, 1, 1),
          priority = c(3, 1, 2),
          stringsAsFactors = FALSE
        )

        out <- ResolveDuplicateIDTime(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          method = "max_complete",
          order_by = "priority"
        )

        testthat::expect_identical(
          out$priority,
          1
        )

        out_dec <- ResolveDuplicateIDTime(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          method = "max_complete",
          order_by = "priority",
          decreasing = TRUE
        )

        testthat::expect_identical(
          out_dec$priority,
          3
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ResolveDuplicateIDTime",
        "validates inputs"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, NA),
          time = c(0, 1),
          y = c(1, 2),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          ResolveDuplicateIDTime(
            data = data,
            id = "id",
            time = "time"
          ),
          "`id` must not contain missing values"
        )

        data2 <- data.frame(
          id = c(1, 1),
          time = c(0, NA),
          y = c(1, 2),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          ResolveDuplicateIDTime(
            data = data2,
            id = "id",
            time = "time"
          ),
          "`time` must not contain missing values"
        )

        testthat::expect_error(
          ResolveDuplicateIDTime(
            data = data2,
            id = "id",
            time = "missing"
          ),
          "not in `data`"
        )
      }
    )
  },
  text = "test-dynTools-resolve-duplicate-id-time"
)
