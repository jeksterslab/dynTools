## ---- test-dynTools-summary-by-id
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "SummaryByID", "summarizes observed missingness and time by ID"
      ),
      {
        data <- data.frame(
          id = c("b", "a", "b", "a", "a"),
          time = c(2, 3, 1, 1, 2),
          y = c(NA, 3, NA, 1, NA),
          x = c(5, 3, NA, 1, 2),
          c = c(0, 1, NA, 1, 1),
          stringsAsFactors = FALSE
        )

        out <- SummaryByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y", "x"),
          covariates = "c"
        )

        expected <- data.frame(
          id = c("a", "b"),
          n_rows = c(3L, 2L),
          n_complete = c(2L, 0L),
          n_missing = c(1L, 3L),
          prop_missing = c(1 / 6, 3 / 4),
          time_min = c(1, 1),
          time_max = c(3, 2),
          n_unique_time = c(3L, 2L),
          n_duplicate_time = c(0L, 0L),
          initial_na = c(FALSE, TRUE),
          all_missing = c(FALSE, FALSE),
          stringsAsFactors = FALSE
        )

        testthat::expect_equal(
          out,
          expected
        )

        testthat::expect_identical(
          rownames(out),
          as.character(seq_len(nrow(out)))
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "SummaryByID",
        "reports duplicate times within ID"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 1),
          time = c(1, 1, 2),
          y = c(1, 2, 3),
          stringsAsFactors = FALSE
        )

        out <- SummaryByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_equal(
          out$n_duplicate_time,
          1L
        )
      }
    )
  },
  text = "test-dynTools-summary-by-id"
)
