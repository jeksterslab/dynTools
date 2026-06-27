## ---- test-dynTools-filter-observed-rows
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
        "FilterObservedRows",
        "keeps rows with at least one observed value",
        "by default and sorts output"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(2, 1, 1, 2, 1),
          time = c(2, 3, 1, 1, 2),
          y1 = c(NA, 3, 1, NA, NA),
          y2 = c(5, 4, NA, NA, NA),
          x = letters[1:5],
          stringsAsFactors = FALSE
        )

        out <- FilterObservedRows(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2")
        )

        testthat::expect_equal(
          nrow(out),
          3L
        )
        testthat::expect_equal(
          out$id,
          c(1, 1, 2)
        )
        testthat::expect_equal(
          out$time,
          c(1, 3, 2)
        )
        testthat::expect_equal(
          out$y1,
          c(1, 3, NA)
        )
        testthat::expect_equal(
          out$y2,
          c(NA, 4, 5)
        )
        testthat::expect_equal(
          out$x,
          c("c", "b", "a")
        )
        testthat::expect_equal(
          rownames(out),
          as.character(seq_len(nrow(out)))
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "FilterObservedRows",
        "uses min_nonmissing to require multiple observed values"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1, 2, 2),
          time = c(1, 2, 3, 1, 2),
          y1 = c(1, NA, 3, NA, 2),
          y2 = c(NA, NA, 4, NA, 3),
          stringsAsFactors = FALSE
        )

        out <- FilterObservedRows(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_nonmissing = 2L
        )

        testthat::expect_equal(
          nrow(out),
          2L
        )
        testthat::expect_equal(
          out$id,
          c(1, 2)
        )
        testthat::expect_equal(
          out$time,
          c(3, 2)
        )
        testthat::expect_equal(
          out$y1,
          c(3, 2)
        )
        testthat::expect_equal(
          out$y2,
          c(4, 3)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "FilterObservedRows",
        "removes IDs with too few retained rows"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(
            rep(1, 3),
            rep(2, 3),
            rep(3, 3)
          ),
          time = rep(1:3, times = 3),
          y1 = c(
            1, 2, 3,
            1, NA, NA,
            NA, NA, NA
          ),
          y2 = c(
            NA, NA, NA,
            NA, 2, NA,
            NA, NA, NA
          ),
          stringsAsFactors = FALSE
        )

        out <- FilterObservedRows(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_nonmissing = 1L,
          min_rows_by_id = 2L
        )

        testthat::expect_equal(
          unique(out$id),
          c(1, 2)
        )
        testthat::expect_equal(
          table(out$id),
          table(c(1, 1, 1, 2, 2))
        )
        testthat::expect_false(
          3 %in% out$id
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "FilterObservedRows",
        "can return zero rows after row filtering"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 2),
          time = c(1, 2, 1),
          y1 = c(NA_real_, NA_real_, NA_real_),
          y2 = c(NA_real_, NA_real_, NA_real_),
          stringsAsFactors = FALSE
        )

        out <- FilterObservedRows(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2")
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
        "FilterObservedRows",
        "can return zero rows after ID-level filtering"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(1, 2, 1, 2),
          y1 = c(1, NA, 2, NA),
          y2 = c(NA_real_, NA_real_, NA_real_, NA_real_),
          stringsAsFactors = FALSE
        )

        out <- FilterObservedRows(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_nonmissing = 1L,
          min_rows_by_id = 2L
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
        "FilterObservedRows",
        "checks filtering arguments"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(1, 2, 3),
          y1 = c(1, 2, 3),
          y2 = c(1, NA, 3),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          FilterObservedRows(
            data = data,
            id = "id",
            time = "time",
            observed = c("y1", "y2"),
            min_nonmissing = 0
          ),
          "`min_nonmissing` must be a positive integer.",
          fixed = TRUE
        )

        testthat::expect_error(
          FilterObservedRows(
            data = data,
            id = "id",
            time = "time",
            observed = c("y1", "y2"),
            min_nonmissing = 3
          ),
          "`min_nonmissing` must be less than or equal to `length(observed)`.",
          fixed = TRUE
        )

        testthat::expect_error(
          FilterObservedRows(
            data = data,
            id = "id",
            time = "time",
            observed = c("y1", "y2"),
            min_rows_by_id = 0
          ),
          "`min_rows_by_id` must be `NULL` or a positive integer.",
          fixed = TRUE
        )

        testthat::expect_error(
          FilterObservedRows(
            data = data,
            id = "id",
            time = "time",
            observed = c("y1", "y2"),
            min_rows_by_id = NA
          ),
          "`min_rows_by_id` must be `NULL` or a positive integer.",
          fixed = TRUE
        )
      }
    )
  },
  text = "test-dynTools-filter-observed-rows"
)
