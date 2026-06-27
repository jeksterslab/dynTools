## ---- test-dynTools-drop-by-id
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
        "drops requested IDs"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 2, 2, 3, 3),
          time = c(1, 2, 1, 2, 1, 2),
          y = seq_len(6)
        )

        out <- DropByID(
          data = data,
          id = "id",
          drop = c(2, 3)
        )

        testthat::expect_s3_class(
          out,
          "data.frame"
        )
        testthat::expect_equal(
          out,
          data.frame(
            id = c(1, 1),
            time = c(1, 2),
            y = c(1, 2)
          )
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
        "returns unchanged data when drop is NULL or empty"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(1, 2, 1, 2),
          y = 1:4
        )
        rownames(data) <- paste0("row", seq_len(nrow(data)))

        out_null <- DropByID(
          data = data,
          id = "id",
          drop = NULL
        )

        out_empty <- DropByID(
          data = data,
          id = "id",
          drop = integer(0)
        )

        expected <- data
        rownames(expected) <- NULL

        testthat::expect_equal(
          out_null,
          expected
        )
        testthat::expect_equal(
          out_empty,
          expected
        )
        testthat::expect_equal(
          rownames(out_null),
          as.character(seq_len(nrow(out_null)))
        )
        testthat::expect_equal(
          rownames(out_empty),
          as.character(seq_len(nrow(out_empty)))
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "ignores IDs that are not present"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(1, 2, 1, 2),
          y = 1:4
        )

        out <- DropByID(
          data = data,
          id = "id",
          drop = c(3, 4)
        )

        testthat::expect_equal(
          out,
          data
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "works with character IDs"
      ),
      {
        data <- data.frame(
          id = c("a", "a", "b", "b", "c"),
          time = c(1, 2, 1, 2, 1),
          y = 1:5
        )

        out <- DropByID(
          data = data,
          id = "id",
          drop = c("b", "c")
        )

        testthat::expect_equal(
          out,
          data.frame(
            id = c("a", "a"),
            time = c(1, 2),
            y = c(1, 2)
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "preserves column order and non-ID columns"
      ),
      {
        data <- data.frame(
          time = c(1, 2, 1, 2),
          id = c(1, 1, 2, 2),
          y1 = c(1.1, 1.2, 2.1, 2.2),
          y2 = c("a", "b", "c", "d")
        )

        out <- DropByID(
          data = data,
          id = "id",
          drop = 2
        )

        testthat::expect_equal(
          names(out),
          names(data)
        )
        testthat::expect_equal(
          out,
          data.frame(
            time = c(1, 2),
            id = c(1, 1),
            y1 = c(1.1, 1.2),
            y2 = c("a", "b")
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "can drop all rows"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 2, 2),
          time = c(1, 2, 1, 2),
          y = 1:4
        )

        out <- DropByID(
          data = data,
          id = "id",
          drop = c(1, 2)
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
          names(data)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "checks input arguments"
      ),
      {
        data <- data.frame(
          id = c(1, 1, 2, 2),
          y = 1:4
        )

        data_duplicate_names <- data
        names(data_duplicate_names) <- c("id", "id")

        testthat::expect_error(
          DropByID(
            data = as.matrix(data),
            id = "id",
            drop = 1
          ),
          "`data` must be a data frame.",
          fixed = TRUE
        )

        testthat::expect_error(
          DropByID(
            data = data_duplicate_names,
            id = "id",
            drop = 1
          ),
          "`data` must have unique column names.",
          fixed = TRUE
        )

        testthat::expect_error(
          DropByID(
            data = data,
            id = character(0),
            drop = 1
          ),
          "`id` must be a non-empty character string.",
          fixed = TRUE
        )

        testthat::expect_error(
          DropByID(
            data = data,
            id = "",
            drop = 1
          ),
          "`id` must be a non-empty character string.",
          fixed = TRUE
        )

        testthat::expect_error(
          DropByID(
            data = data,
            id = NA_character_,
            drop = 1
          ),
          "`id` must be a non-empty character string.",
          fixed = TRUE
        )

        testthat::expect_error(
          DropByID(
            data = data,
            id = "person",
            drop = 1
          ),
          "`id` is not in `data`: person.",
          fixed = TRUE
        )
      }
    )
  },
  text = "test-dynTools-drop-by-id"
)
