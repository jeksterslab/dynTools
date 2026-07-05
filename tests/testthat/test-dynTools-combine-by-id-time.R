## ---- test-dynTools-combine-by-id-time
lapply(
  X = 1,
  FUN = function(i, text) {
    message(text)

    if (!identical(Sys.getenv("NOT_CRAN"), "true") && !interactive()) {
      message("CRAN: tests skipped.")
      # nolint start
      return(invisible(NULL))
      # nolint end
    }

    testthat::test_that(
      paste(
        text,
        "CombineByIDTime",
        "appends observed variables by id and time"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(2L, 1L, 1L, 2L),
          time = c(3L, 1L, 2L, 1L),
          cov = c(203L, 101L, 102L, 201L),
          extra = 1:4
        )

        append_data <- data.frame(
          id = c(1L, 2L, 2L),
          time = c(1L, 1L, 3L),
          y1 = c(11, 21, 23),
          y2 = c(111, 121, 123)
        )

        out <- CombineByIDTime(
          data = data,
          append_data = append_data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          covariates = "cov"
        )

        expected <- data.frame(
          id = c(1L, 1L, 2L, 2L),
          time = c(1L, 2L, 1L, 3L),
          cov = c(101L, 102L, 201L, 203L),
          y1 = c(11, NA, 21, 23),
          y2 = c(111, NA, 121, 123)
        )

        testthat::expect_identical(
          out,
          expected
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "CombineByIDTime",
        "ignores append_data rows not present in data"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = 1L,
          time = 1L
        )

        append_data <- data.frame(
          id = c(1L, 1L, 2L),
          time = c(1L, 2L, 1L),
          y = c(10, 20, 30)
        )

        out <- CombineByIDTime(
          data = data,
          append_data = append_data,
          id = "id",
          time = "time",
          observed = "y"
        )

        expected <- data.frame(
          id = 1L,
          time = 1L,
          y = 10
        )

        testthat::expect_identical(
          out,
          expected
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "CombineByIDTime",
        "inserts missing values when append_data is empty"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1L, 1L),
          time = c(1L, 2L)
        )

        append_data <- data.frame(
          id = integer(0),
          time = integer(0),
          y = numeric(0)
        )

        out <- CombineByIDTime(
          data = data,
          append_data = append_data,
          id = "id",
          time = "time",
          observed = "y"
        )

        expected <- data.frame(
          id = c(1L, 1L),
          time = c(1L, 2L),
          y = c(NA_real_, NA_real_)
        )

        testthat::expect_identical(
          out,
          expected
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "CombineByIDTime",
        "requires unique id-time combinations in data"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1L, 1L),
          time = c(1L, 1L)
        )

        append_data <- data.frame(
          id = 1L,
          time = 1L,
          y = 10
        )

        testthat::expect_error(
          CombineByIDTime(
            data = data,
            append_data = append_data,
            id = "id",
            time = "time",
            observed = "y"
          ),
          regexp = "unique `id`-`time` combinations"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "CombineByIDTime",
        "requires unique id-time combinations in append_data"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1L, 1L),
          time = c(1L, 2L)
        )

        append_data <- data.frame(
          id = c(1L, 1L),
          time = c(1L, 1L),
          y = c(10, 11)
        )

        testthat::expect_error(
          CombineByIDTime(
            data = data,
            append_data = append_data,
            id = "id",
            time = "time",
            observed = "y"
          ),
          regexp = "unique `id`-`time` combinations"
        )
      }
    )
  },
  text = "test-dynTools-combine-by-id-time"
)
