## ---- test-dynTools-filter-by-id
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "FilterByID",
        "removes IDs that do not meet data requirements"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(3, 1, 2, 1, 3, 1, 2),
          time = c(1, 1, 1, 2, 2, 3, 2),
          y = c(1, 1, NA, 2, NA, 3, 4),
          stringsAsFactors = FALSE
        )

        out <- FilterByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          min_rows = 2,
          min_complete = 2,
          max_prop_missing = 0.50
        )

        expected <- data.frame(
          id = c(1, 1, 1),
          time = c(1, 2, 3),
          y = c(1, 2, 3),
          stringsAsFactors = FALSE
        )

        testthat::expect_identical(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        "FilterByID",
        "can remove IDs with initial missing values"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(1, 2, 1, 2),
          y = c(1, 2, NA, 3),
          stringsAsFactors = FALSE
        )

        out <- FilterByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          min_rows = 2,
          min_complete = 1,
          max_prop_missing = 0.50,
          allow_initial_na = FALSE
        )

        expected <- data.frame(
          id = c(1, 1),
          time = c(1, 2),
          y = c(1, 2),
          stringsAsFactors = FALSE
        )

        testthat::expect_identical(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        "FilterByID",
        "validates filtering arguments"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1),
          time = c(1, 2),
          y = c(1, 2),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          FilterByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            max_prop_missing = 2
          ),
          "`max_prop_missing`"
        )
      }
    )
  },
  text = "test-dynTools-filter-by-id"
)
