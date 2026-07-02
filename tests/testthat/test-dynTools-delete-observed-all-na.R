## ---- test-dynTools-delete-observed-all-na

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
        "DeleteObservedAllNA",
        "deletes rows where all observed variables are missing"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(2L, 1L, 1L, 2L, 1L, 2L, 3L, 3L),
          time = c(2L, 1L, 2L, 1L, 3L, 3L, 1L, 2L),
          y1 = c(20, NA, NA, NA, 3, NA, NA, 30),
          y2 = c(NA, NA, 2, NA, 3, NA, NA, NA),
          y3 = c(20, NA, NA, NA, 3, NA, NA, NA),
          cov = c(2, 1, NA, 4, 3, 6, 7, 8)
        )

        out <- DeleteObservedAllNA(
          data = data,
          id = "id",
          time = "time",
          observed = paste0("y", 1:3),
          covariates = "cov"
        )

        expected <- data.frame(
          id = c(1L, 1L, 2L, 3L),
          time = c(2L, 3L, 2L, 2L),
          y1 = c(NA, 3, 20, 30),
          y2 = c(2, 3, NA, NA),
          y3 = c(NA, 3, 20, NA),
          cov = c(NA, 3, 2, 8)
        )

        testthat::expect_identical(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        "DeleteObservedAllNA",
        "keeps rows with at least one observed variable present"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1L, 1L, 1L),
          time = c(1L, 2L, 3L),
          y1 = c(1, NA, NA),
          y2 = c(NA, 2, NA),
          y3 = c(NA, NA, 3),
          cov = c(NA, NA, NA)
        )

        out <- DeleteObservedAllNA(
          data = data,
          id = "id",
          time = "time",
          observed = paste0("y", 1:3),
          covariates = "cov"
        )

        testthat::expect_identical(out, data)
      }
    )

    testthat::test_that(
      paste(
        text,
        "DeleteObservedAllNA",
        "returns empty data when all rows have all observed variables missing"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1L, 1L, 2L),
          time = c(1L, 2L, 1L),
          y1 = c(NA_real_, NA_real_, NA_real_),
          y2 = c(NA_real_, NA_real_, NA_real_),
          cov = c(1, 2, 3)
        )

        out <- DeleteObservedAllNA(
          data = data,
          id = "id",
          time = "time",
          observed = paste0("y", 1:2),
          covariates = "cov"
        )

        expected <- data[
          integer(0), ,
          drop = FALSE
        ]

        rownames(expected) <- NULL

        testthat::expect_identical(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        "DeleteObservedAllNA",
        "handles empty data frames"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = integer(0),
          time = integer(0),
          y1 = numeric(0),
          y2 = numeric(0)
        )

        out <- DeleteObservedAllNA(
          data = data,
          id = "id",
          time = "time",
          observed = paste0("y", 1:2)
        )

        testthat::expect_identical(out, data)
      }
    )
  },
  text = "test-dynTools-delete-observed-all-na"
)
