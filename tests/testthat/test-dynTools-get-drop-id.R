## ---- test-dynTools-get-drop-id
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
        "GetDropID",
        "returns sensitivity-drop candidate IDs by default"
      ),
      {
        testthat::skip_on_cran()

        x <- data.frame(
          id = c(101, 102, 103, 104),
          flag_any = c(FALSE, TRUE, TRUE, TRUE),
          drop_sensitivity_candidate = c(FALSE, TRUE, FALSE, TRUE),
          stringsAsFactors = FALSE
        )

        out <- GetDropID(
          x = x
        )

        testthat::expect_equal(
          out,
          c(102, 104)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "GetDropID",
        "returns all flagged IDs when flagged_only is false"
      ),
      {
        testthat::skip_on_cran()

        x <- data.frame(
          id = c("id_1", "id_2", "id_3", "id_4"),
          flag_any = c(FALSE, TRUE, TRUE, FALSE),
          drop_sensitivity_candidate = c(FALSE, TRUE, FALSE, FALSE),
          stringsAsFactors = FALSE
        )

        out <- GetDropID(
          x = x,
          flagged_only = FALSE
        )

        testthat::expect_equal(
          out,
          c("id_2", "id_3")
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "GetDropID",
        "returns an empty ID vector when no IDs match"
      ),
      {
        testthat::skip_on_cran()

        x <- data.frame(
          id = c(1, 2, 3),
          flag_any = c(FALSE, FALSE, FALSE),
          drop_sensitivity_candidate = c(FALSE, FALSE, FALSE),
          stringsAsFactors = FALSE
        )

        out_drop <- GetDropID(
          x = x
        )

        out_flag <- GetDropID(
          x = x,
          flagged_only = FALSE
        )

        testthat::expect_equal(
          out_drop,
          numeric(0)
        )

        testthat::expect_equal(
          out_flag,
          numeric(0)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "GetDropID",
        "only requires drop_sensitivity_candidate when flagged_only is true"
      ),
      {
        testthat::skip_on_cran()

        x <- data.frame(
          id = c(1, 2, 3),
          drop_sensitivity_candidate = c(TRUE, FALSE, TRUE),
          stringsAsFactors = FALSE
        )

        out <- GetDropID(
          x = x,
          flagged_only = TRUE
        )

        testthat::expect_equal(
          out,
          c(1, 3)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "GetDropID",
        "only requires flag_any when flagged_only is false"
      ),
      {
        testthat::skip_on_cran()

        x <- data.frame(
          id = c(1, 2, 3),
          flag_any = c(FALSE, TRUE, TRUE),
          stringsAsFactors = FALSE
        )

        out <- GetDropID(
          x = x,
          flagged_only = FALSE
        )

        testthat::expect_equal(
          out,
          c(2, 3)
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "GetDropID",
        "checks input arguments and required columns"
      ),
      {
        testthat::skip_on_cran()

        x <- data.frame(
          id = c(1, 2, 3),
          flag_any = c(FALSE, TRUE, TRUE),
          drop_sensitivity_candidate = c(FALSE, TRUE, FALSE),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          GetDropID(
            x = "not a data frame"
          ),
          "`x` must be a data frame returned by `FlagDiagnosticsByID()`.",
          fixed = TRUE
        )

        testthat::expect_error(
          GetDropID(
            x = x[, setdiff(names(x), "id"), drop = FALSE]
          ),
          "`x` must contain an `id` column.",
          fixed = TRUE
        )

        testthat::expect_error(
          GetDropID(
            x = x,
            flagged_only = NA
          ),
          "`flagged_only` must be `TRUE` or `FALSE`.",
          fixed = TRUE
        )

        testthat::expect_error(
          GetDropID(
            x = x,
            flagged_only = c(TRUE, FALSE)
          ),
          "`flagged_only` must be `TRUE` or `FALSE`.",
          fixed = TRUE
        )

        testthat::expect_error(
          GetDropID(
            x = x[, setdiff(names(x), "drop_sensitivity_candidate"), drop = FALSE],
            flagged_only = TRUE
          ),
          "`x` must contain a `drop_sensitivity_candidate` column.",
          fixed = TRUE
        )

        testthat::expect_error(
          GetDropID(
            x = x[, setdiff(names(x), "flag_any"), drop = FALSE],
            flagged_only = FALSE
          ),
          "`x` must contain a `flag_any` column.",
          fixed = TRUE
        )
      }
    )
  },
  text = "test-dynTools-get-drop-id"
)
