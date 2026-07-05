## ---- test-dynTools-plot-by-id
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
        "coverage"
      ),
      {
        testthat::skip_on_cran()

        file <- tempfile(
          fileext = ".pdf"
        )

        grDevices::pdf(file)
        on.exit(
          grDevices::dev.off(),
          add = TRUE
        )

        data <- data.frame(
          id = rep(1:4, each = 5),
          time = rep(1:5, times = 4),
          y1 = c(
            1, 2, 3, 4, 5,
            2, 3, 4, 5, 6,
            3, 4, 5, 6, 7,
            4, 5, 6, 7, 8
          ),
          y2 = c(
            5, 4, 3, 2, 1,
            6, 5, 4, 3, 2,
            7, 6, 5, 4, 3,
            8, 7, 6, 5, 4
          ),
          y3 = c(
            1, 1, 2, 2, 3,
            2, 2, 3, 3, 4,
            3, 3, 4, 4, 5,
            4, 4, 5, 5, 6
          )
        )
        data

        out_all <- PlotByID(
          data = data,
          id = "id",
          time = "time",
          observed = paste0("y", 1:3),
          ask = FALSE
        )

        testthat::expect_identical(
          out_all,
          1:4
        )

        out_subset <- PlotByID(
          data = data,
          id = "id",
          time = "time",
          observed = paste0("y", 1:3),
          ids = 1:3,
          times = c(1, 3),
          legend = TRUE,
          ask = FALSE
        )

        testthat::expect_identical(
          out_subset,
          1:3
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "treats non-finite observed values as missing for plotting"
      ),
      {
        testthat::skip_on_cran()

        file <- tempfile(
          fileext = ".pdf"
        )

        grDevices::pdf(file)
        on.exit(
          grDevices::dev.off(),
          add = TRUE
        )

        data <- data.frame(
          id = c(1L, 1L, 2L, 2L),
          time = c(0, 1, 0, 1),
          y = c(1, Inf, NaN, 2)
        )

        out <- PlotByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          ask = FALSE
        )

        testthat::expect_identical(
          out,
          1:2
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "errors when time has no finite values"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1L, 1L),
          time = c(Inf, NA),
          y = c(1, 2)
        )

        testthat::expect_error(
          PlotByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            ask = FALSE
          ),
          "`time` contains no finite values",
          fixed = TRUE
        )
      }
    )
  },
  text = "test-dynTools-plot-by-id"
)
