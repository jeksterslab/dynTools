## ---- test-dynTools-trim-initial-rows-by-id
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
        "trims leading rows until minimum nonmissing threshold is met"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 1, 1, 2, 2, 2, 2),
          time = c(1, 2, 3, 4, 1, 2, 3, 4),
          y1 = c(NA, 1, 2, NA, NA, NA, 5, 6),
          y2 = c(NA, NA, 2, NA, NA, 4, 5, 6)
        )

        out <- TrimInitialRowsByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_nonmissing = 1
        )

        expected <- data.frame(
          id = c(1, 1, 1, 2, 2, 2),
          time = c(2, 3, 4, 2, 3, 4),
          y1 = c(1, 2, NA, NA, 5, 6),
          y2 = c(NA, 2, NA, 4, 5, 6)
        )

        testthat::expect_s3_class(
          out,
          "data.frame"
        )
        testthat::expect_equal(
          out,
          expected
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
        "uses stricter minimum nonmissing threshold when requested"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 1, 2, 2, 2),
          time = c(1, 2, 3, 1, 2, 3),
          y1 = c(NA, 1, 2, NA, 3, 4),
          y2 = c(NA, NA, 2, NA, NA, 4)
        )

        out <- TrimInitialRowsByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_nonmissing = 2
        )

        expected <- data.frame(
          id = c(1, 2),
          time = c(3, 3),
          y1 = c(2, 4),
          y2 = c(2, 4)
        )

        testthat::expect_equal(
          out,
          expected
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "drops IDs with no rows meeting the threshold"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 2, 2, 3, 3),
          time = c(1, 2, 1, 2, 1, 2),
          y1 = c(NA, NA, 1, 2, NA, 3),
          y2 = c(NA, NA, NA, 2, NA, NA)
        )

        out <- TrimInitialRowsByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_nonmissing = 1
        )

        expected <- data.frame(
          id = c(2, 2, 3),
          time = c(1, 2, 2),
          y1 = c(1, 2, 3),
          y2 = c(NA, 2, NA)
        )

        testthat::expect_equal(
          out,
          expected
        )
        testthat::expect_false(
          1 %in% out$id
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "can return a zero-row data frame"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(1, 2, 1, 2),
          y1 = c(NA_real_, NA_real_, NA_real_, NA_real_),
          y2 = c(NA_real_, NA_real_, NA_real_, NA_real_)
        )

        out <- TrimInitialRowsByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_nonmissing = 1
        )

        testthat::expect_s3_class(
          out,
          "data.frame"
        )
        testthat::expect_equal(
          nrow(out),
          0L
        )
        testthat::expect_equal(
          names(out),
          c("id", "time", "y1", "y2")
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "sorts by ID and time before trimming"
      ),
      {
        data <- data.frame(
          id = c(2, 1, 1, 2, 1, 2),
          time = c(2, 3, 1, 1, 2, 3),
          y1 = c(2, 3, NA, NA, 2, 3),
          y2 = c(2, 3, NA, NA, NA, 3)
        )

        out <- TrimInitialRowsByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_nonmissing = 1
        )

        expected <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(2, 3, 2, 3),
          y1 = c(2, 3, 2, 3),
          y2 = c(NA, 3, 2, 3)
        )

        testthat::expect_equal(
          out,
          expected
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "preserves requested covariates and drops unrequested columns"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 1, 2, 2, 2),
          time = c(1, 2, 3, 1, 2, 3),
          y = c(NA, 1, 2, NA, 3, 4),
          x = c("a", "b", "c", "d", "e", "f"),
          unused = 11:16,
          stringsAsFactors = FALSE
        )

        out <- TrimInitialRowsByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          covariates = "x",
          min_nonmissing = 1
        )

        expected <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(2, 3, 2, 3),
          y = c(1, 2, 3, 4),
          x = c("b", "c", "e", "f"),
          stringsAsFactors = FALSE
        )

        testthat::expect_equal(
          names(out),
          c("id", "time", "y", "x")
        )
        testthat::expect_equal(
          out,
          expected
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "handles character IDs"
      ),
      {
        data <- data.frame(
          id = c("b", "b", "a", "a", "c", "c"),
          time = c(1, 2, 1, 2, 1, 2),
          y1 = c(NA, 2, NA, 1, NA, NA),
          y2 = c(NA, 2, NA, NA, NA, 3),
          stringsAsFactors = FALSE
        )

        out <- TrimInitialRowsByID(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          min_nonmissing = 1
        )

        expected <- data.frame(
          id = c("a", "b", "c"),
          time = c(2, 2, 2),
          y1 = c(1, 2, NA),
          y2 = c(NA, 2, 3),
          stringsAsFactors = FALSE
        )

        testthat::expect_equal(
          out,
          expected
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "allows duplicate ID-time rows"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 1, 1),
          time = c(1, 1, 2, 2),
          y = c(NA, 1, 2, 3)
        )

        out <- TrimInitialRowsByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          min_nonmissing = 1
        )

        expected <- data.frame(
          id = c(1, 1, 1),
          time = c(1, 2, 2),
          y = c(1, 2, 3)
        )

        testthat::expect_equal(
          out,
          expected
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "allows nonnumeric time variables"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 1),
          time = c("t1", "t2", "t3"),
          y = c(NA, 1, 2),
          stringsAsFactors = FALSE
        )

        out <- TrimInitialRowsByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          min_nonmissing = 1
        )

        expected <- data.frame(
          id = c(1, 1),
          time = c("t2", "t3"),
          y = c(1, 2),
          stringsAsFactors = FALSE
        )

        testthat::expect_equal(
          out,
          expected
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "checks TrimInitialRowsByID-specific input arguments"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(1, 2, 1, 2),
          y1 = c(1, 2, 3, 4),
          y2 = c(1, 2, 3, 4)
        )

        testthat::expect_error(
          TrimInitialRowsByID(
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
          TrimInitialRowsByID(
            data = data,
            id = "id",
            time = "time",
            observed = c("y1", "y2"),
            min_nonmissing = 1.5
          ),
          "`min_nonmissing` must be a positive integer.",
          fixed = TRUE
        )

        testthat::expect_error(
          TrimInitialRowsByID(
            data = data,
            id = "id",
            time = "time",
            observed = c("y1", "y2"),
            min_nonmissing = NA_integer_
          ),
          "`min_nonmissing` must be a positive integer.",
          fixed = TRUE
        )

        testthat::expect_error(
          TrimInitialRowsByID(
            data = data,
            id = "id",
            time = "time",
            observed = c("y1", "y2"),
            min_nonmissing = 3L
          ),
          "`min_nonmissing` must be less than or equal to `length(observed)`.",
          fixed = TRUE
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "checks delegated input arguments"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(1, 2, 1, 2),
          y = c(1, 2, 3, 4)
        )

        data_duplicate_names <- data
        names(data_duplicate_names) <- c("id", "id", "time")

        testthat::expect_error(
          TrimInitialRowsByID(
            data = as.matrix(data),
            id = "id",
            time = "time",
            observed = "y"
          ),
          "`data` must be a data frame.",
          fixed = TRUE
        )

        testthat::expect_error(
          TrimInitialRowsByID(
            data = data_duplicate_names,
            id = "id",
            time = "time",
            observed = "y"
          ),
          "`data` must have unique column names.",
          fixed = TRUE
        )

        testthat::expect_error(
          TrimInitialRowsByID(
            data = data,
            id = character(0),
            time = "time",
            observed = "y"
          ),
          "`id` must be a non-empty character string.",
          fixed = TRUE
        )

        testthat::expect_error(
          TrimInitialRowsByID(
            data = data,
            id = "id",
            time = character(0),
            observed = "y"
          ),
          "`time` must be a non-empty character string.",
          fixed = TRUE
        )

        testthat::expect_error(
          TrimInitialRowsByID(
            data = data,
            id = "id",
            time = "time",
            observed = character(0)
          ),
          "`observed` must be a non-empty character vector.",
          fixed = TRUE
        )

        testthat::expect_error(
          TrimInitialRowsByID(
            data = data,
            id = "id",
            time = "time",
            observed = "z"
          ),
          "The following variables are missing from `data`: z.",
          fixed = TRUE
        )

        testthat::expect_error(
          TrimInitialRowsByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            covariates = NA_character_
          ),
          "`covariates` must be `NULL` or a character vector.",
          fixed = TRUE
        )

        testthat::expect_error(
          TrimInitialRowsByID(
            data = data.frame(
              id = c(1, NA),
              time = c(1, 2),
              y = c(1, 2)
            ),
            id = "id",
            time = "time",
            observed = "y"
          ),
          "`id` must not contain missing values.",
          fixed = TRUE
        )

        testthat::expect_error(
          TrimInitialRowsByID(
            data = data.frame(
              id = c(1, 1),
              time = c(1, NA),
              y = c(1, 2)
            ),
            id = "id",
            time = "time",
            observed = "y"
          ),
          "`time` must not contain missing values.",
          fixed = TRUE
        )

        testthat::expect_error(
          TrimInitialRowsByID(
            data = data.frame(
              id = c(1, 1),
              time = c(1, 2),
              y = c("a", "b"),
              stringsAsFactors = FALSE
            ),
            id = "id",
            time = "time",
            observed = "y"
          ),
          "Observed variables must be numeric. Non-numeric: y.",
          fixed = TRUE
        )
      }
    )
  },
  text = "test-dynTools-trim-initial-rows-by-id"
)
