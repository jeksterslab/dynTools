## ---- test-dynTools-get-observed-initial
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
        "GetObservedInitial",
        "selects the first row per ID after sorting by ID and time"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(2, 1, 3, 1, 2, 3),
          time = c(2, 2, 2, 1, 1, 1),
          y1 = c(20, 10, 30, 1, 2, 3),
          y2 = c(200, 100, 300, 4, 6, 5),
          stringsAsFactors = FALSE
        )

        out <- GetObservedInitial(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2")
        )

        expected_data <- data.frame(
          y1 = c(1, 2, 3),
          y2 = c(4, 6, 5)
        )

        testthat::expect_equal(
          out$data,
          expected_data,
          ignore_attr = TRUE
        )

        testthat::expect_equal(
          out$mean,
          c(y1 = 2, y2 = 5),
          tolerance = 1e-12
        )

        testthat::expect_equal(
          out$cov,
          stats::cov(expected_data),
          tolerance = 1e-12
        )

        testthat::expect_equal(
          out$n,
          3L
        )

        testthat::expect_equal(
          out$n_complete,
          3L
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "GetObservedInitial",
        "ignores missing values in means and uses complete cases for covariance"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = c(1, 1, 2, 2, 3, 3, 4, 4),
          time = c(1, 2, 1, 2, 1, 2, 1, 2),
          y1 = c(1, 10, NA, 20, 3, 30, 4, 40),
          y2 = c(2, 10, 5, 20, 7, 30, 8, 40),
          stringsAsFactors = FALSE
        )

        out <- GetObservedInitial(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2")
        )

        expected_data <- data.frame(
          y1 = c(1, NA, 3, 4),
          y2 = c(2, 5, 7, 8)
        )

        expected_cov_data <- data.frame(
          y1 = c(1, 3, 4),
          y2 = c(2, 7, 8)
        )

        testthat::expect_equal(
          out$data,
          expected_data,
          ignore_attr = TRUE
        )

        testthat::expect_equal(
          out$mean,
          c(
            y1 = mean(c(1, 3, 4)),
            y2 = mean(c(2, 5, 7, 8))
          ),
          tolerance = 1e-12
        )

        testthat::expect_equal(
          out$cov,
          stats::cov(expected_cov_data),
          tolerance = 1e-12
        )

        testthat::expect_equal(
          out$n,
          4L
        )

        testthat::expect_equal(
          out$n_complete,
          3L
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "GetObservedInitial",
        "adds ridge to the covariance matrix when it is not positive definite"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = rep(1:3, each = 2),
          time = rep(1:2, times = 3),
          y1 = c(1, 10, 2, 20, 3, 30),
          y2 = c(2, 10, 4, 20, 6, 30),
          stringsAsFactors = FALSE
        )

        ridge <- 0.25

        out <- GetObservedInitial(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          ridge = ridge
        )

        expected_data <- data.frame(
          y1 = c(1, 2, 3),
          y2 = c(2, 4, 6)
        )

        expected_cov <- stats::cov(expected_data) +
          diag(ridge, nrow = length(c("y1", "y2")))

        testthat::expect_equal(
          out$cov,
          expected_cov,
          tolerance = 1e-12
        )

        testthat::expect_true(
          all(
            eigen(
              out$cov,
              symmetric = TRUE,
              only.values = TRUE
            )$values > 0
          )
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "GetObservedInitial",
        "does not add ridge when the covariance matrix is positive definite"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = rep(1:4, each = 2),
          time = rep(1:2, times = 4),
          y1 = c(1, 10, 2, 20, 3, 30, 4, 40),
          y2 = c(1, 10, 4, 20, 2, 30, 5, 40),
          stringsAsFactors = FALSE
        )

        out <- GetObservedInitial(
          data = data,
          id = "id",
          time = "time",
          observed = c("y1", "y2"),
          ridge = 10
        )

        expected_data <- data.frame(
          y1 = c(1, 2, 3, 4),
          y2 = c(1, 4, 2, 5)
        )

        testthat::expect_equal(
          out$cov,
          stats::cov(expected_data),
          tolerance = 1e-12
        )
      }
    )

    testthat::test_that(
      paste(
        text,
        "GetObservedInitial",
        "works with a single observed variable"
      ),
      {
        testthat::skip_on_cran()

        data <- data.frame(
          id = rep(1:3, each = 2),
          time = rep(1:2, times = 3),
          y = c(1, 10, 2, 20, 3, 30),
          stringsAsFactors = FALSE
        )

        out <- GetObservedInitial(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        testthat::expect_equal(
          out$data,
          data.frame(y = c(1, 2, 3)),
          ignore_attr = TRUE
        )

        testthat::expect_equal(
          out$mean,
          c(y = 2),
          tolerance = 1e-12
        )

        testthat::expect_equal(
          out$cov,
          matrix(
            stats::var(c(1, 2, 3)),
            nrow = 1L,
            dimnames = list("y", "y")
          ),
          tolerance = 1e-12
        )

        testthat::expect_equal(
          out$n,
          3L
        )

        testthat::expect_equal(
          out$n_complete,
          3L
        )
      }
    )
  },
  text = "test-dynTools-get-observed-initial"
)
