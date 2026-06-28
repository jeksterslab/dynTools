## ---- test-dynTools-detrend-by-id
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
        "DetrendByID",
        "appends linear detrended variables by ID preserving means"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = rep(1:2, each = 4),
          time = rep(1:4, times = 2),
          y = 2 + 3 * rep(1:4, times = 2),
          stringsAsFactors = FALSE
        )

        out <- DetrendByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          degree = 1,
          replace = FALSE,
          warn_skipped = FALSE,
          drop_skipped_ids = FALSE
        )

        testthat::expect_true("detrend_y" %in% names(out))
        testthat::expect_equal(
          out$detrend_y,
          rep(9.5, 8),
          tolerance = 1e-12
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DetrendByID",
        "can return ordinary linear residuals when keep_mean is false"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = rep(1:2, each = 4),
          time = rep(1:4, times = 2),
          y = 2 + 3 * rep(1:4, times = 2),
          stringsAsFactors = FALSE
        )

        out <- DetrendByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          degree = 1,
          replace = FALSE,
          keep_mean = FALSE,
          warn_skipped = FALSE,
          drop_skipped_ids = FALSE
        )

        testthat::expect_true("detrend_y" %in% names(out))
        testthat::expect_equal(
          out$detrend_y,
          rep(0, 8),
          tolerance = 1e-12
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DetrendByID",
        "preserves original values when degree is zero and keep_mean is true"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1, 2, 2, 2),
          time = c(1, 2, 3, 1, 2, 3),
          y = c(1, 2, 3, 2, 2, 4),
          stringsAsFactors = FALSE
        )

        out <- DetrendByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          degree = 0,
          replace = FALSE,
          keep_mean = TRUE,
          warn_skipped = FALSE,
          drop_skipped_ids = FALSE
        )

        testthat::expect_equal(
          out$detrend_y,
          data$y,
          tolerance = 1e-12
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DetrendByID",
        "mean-centers by ID when degree is zero and keep_mean is false"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1, 2, 2, 2),
          time = c(1, 2, 3, 1, 2, 3),
          y = c(1, 2, 3, 2, 2, 4),
          stringsAsFactors = FALSE
        )

        out <- DetrendByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          degree = 0,
          replace = FALSE,
          keep_mean = FALSE,
          warn_skipped = FALSE,
          drop_skipped_ids = FALSE
        )

        testthat::expect_equal(
          out$detrend_y,
          c(-1, 0, 1, -2 / 3, -2 / 3, 4 / 3),
          tolerance = 1e-12
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DetrendByID",
        "preserves missing observations as missing detrended values"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(1, 2, 3),
          y = c(1, NA, 3),
          stringsAsFactors = FALSE
        )

        out <- DetrendByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          degree = 1,
          replace = FALSE,
          warn_skipped = FALSE,
          drop_skipped_ids = FALSE
        )

        testthat::expect_equal(
          out$detrend_y[c(1, 3)],
          c(2, 2),
          tolerance = 1e-12
        )
        testthat::expect_true(is.na(out$detrend_y[2]))
      }
    )

    testthat::test_that(
      paste(
        text,
        "DetrendByID",
        "preserves missing observations as missing residuals",
        "when keep_mean is false"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(1, 2, 3),
          y = c(1, NA, 3),
          stringsAsFactors = FALSE
        )

        out <- DetrendByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          degree = 1,
          replace = FALSE,
          keep_mean = FALSE,
          warn_skipped = FALSE,
          drop_skipped_ids = FALSE
        )

        testthat::expect_equal(
          out$detrend_y[c(1, 3)],
          c(0, 0),
          tolerance = 1e-12
        )
        testthat::expect_true(is.na(out$detrend_y[2]))
      }
    )

    testthat::test_that(
      paste(
        text,
        "DetrendByID",
        "can replace observed variables preserving means"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = rep(1:2, each = 3),
          time = rep(1:3, times = 2),
          y = 1 + 2 * rep(1:3, times = 2),
          stringsAsFactors = FALSE
        )

        out <- DetrendByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          degree = 1,
          replace = TRUE,
          warn_skipped = FALSE,
          drop_skipped_ids = FALSE
        )

        testthat::expect_false("detrend_y" %in% names(out))
        testthat::expect_equal(
          out$y,
          rep(5, 6),
          tolerance = 1e-12
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DetrendByID",
        "can replace observed variables with ordinary residuals"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = rep(1:2, each = 3),
          time = rep(1:3, times = 2),
          y = 1 + 2 * rep(1:3, times = 2),
          stringsAsFactors = FALSE
        )

        out <- DetrendByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          degree = 1,
          replace = TRUE,
          keep_mean = FALSE,
          warn_skipped = FALSE,
          drop_skipped_ids = FALSE
        )

        testthat::expect_false("detrend_y" %in% names(out))
        testthat::expect_equal(
          out$y,
          rep(0, 6),
          tolerance = 1e-12
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DetrendByID",
        "keeps original values when trend cannot be estimated"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 1),
          time = c(1, 1, 1),
          y = c(1, 2, 3),
          stringsAsFactors = FALSE
        )

        out <- DetrendByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y",
          degree = 1,
          replace = FALSE,
          warn_skipped = FALSE,
          drop_skipped_ids = FALSE
        )

        testthat::expect_equal(
          out$detrend_y,
          data$y,
          tolerance = 1e-12
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DetrendByID",
        "checks for detrended name collisions"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1),
          time = c(1, 2),
          y = c(1, 2),
          detrend_y = c(0, 0),
          stringsAsFactors = FALSE
        )

        testthat::expect_error(
          DetrendByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            replace = FALSE,
            warn_skipped = FALSE,
            drop_skipped_ids = FALSE
          ),
          "already exist"
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DetrendByID",
        "checks keep_mean"
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
          DetrendByID(
            data = data,
            id = "id",
            time = "time",
            observed = "y",
            keep_mean = NA,
            warn_skipped = FALSE,
            drop_skipped_ids = FALSE
          ),
          "`keep_mean` must be `TRUE` or `FALSE`",
          fixed = TRUE
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "DetrendByID",
        "handles all combinations of warn_skipped and drop_skipped_ids"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(
            rep(1, 3),
            rep(2, 3)
          ),
          time = c(
            1, 2, 3,
            1, 1, 1
          ),
          y = c(
            3, 5, 7,
            10, 20, 30
          ),
          stringsAsFactors = FALSE
        )

        settings <- expand.grid(
          warn_skipped = c(FALSE, TRUE),
          drop_skipped_ids = c(FALSE, TRUE)
        )

        for (i in seq_len(nrow(settings))) {
          warn_skipped <- settings$warn_skipped[i]
          drop_skipped_ids <- settings$drop_skipped_ids[i]

          expr <- quote(
            DetrendByID(
              data = data,
              id = "id",
              time = "time",
              observed = "y",
              degree = 1,
              replace = FALSE,
              warn_skipped = warn_skipped,
              drop_skipped_ids = drop_skipped_ids
            )
          )

          if (warn_skipped) {
            out <- testthat::expect_warning(
              eval(expr),
              "could not be detrended"
            )
          } else {
            out <- testthat::expect_warning(
              eval(expr),
              NA
            )
          }

          skipped <- attr(
            x = out,
            which = "detrend_skipped"
          )

          testthat::expect_s3_class(
            skipped,
            "data.frame"
          )
          testthat::expect_equal(
            nrow(skipped),
            1L
          )
          testthat::expect_equal(
            skipped$id,
            2
          )
          testthat::expect_equal(
            skipped$variable,
            "y"
          )
          testthat::expect_equal(
            skipped$reason,
            "too few unique time values"
          )

          if (drop_skipped_ids) {
            testthat::expect_equal(
              unique(out$id),
              1
            )
            testthat::expect_equal(
              nrow(out),
              3L
            )
            testthat::expect_equal(
              out$detrend_y,
              rep(5, 3),
              tolerance = 1e-12
            )
          } else {
            testthat::expect_equal(
              unique(out$id),
              c(1, 2)
            )
            testthat::expect_equal(
              nrow(out),
              6L
            )
            testthat::expect_equal(
              out$detrend_y[out$id == 1],
              rep(5, 3),
              tolerance = 1e-12
            )
            testthat::expect_equal(
              out$detrend_y[out$id == 2],
              data$y[data$id == 2],
              tolerance = 1e-12
            )
          }
        }
      }
    )
  },
  text = "test-dynTools-detrend-by-id"
)
