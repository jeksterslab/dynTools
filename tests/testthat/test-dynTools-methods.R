## ---- test-dynTools-methods
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "print.dynutillist prints list contents without metadata"
      ),
      {
        data <- data.frame(
          id = c(1L, 1L, 2L),
          time = c(1L, 2L, 1L),
          y = c(10, 20, 30)
        )

        out <- SubsetByID(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        printed <- utils::capture.output(print(out))

        testthat::expect_true(any(grepl("1", printed, fixed = TRUE)))
        testthat::expect_true(any(grepl("2", printed, fixed = TRUE)))
        testthat::expect_false(any(grepl("args", printed, fixed = TRUE)))
        testthat::expect_false(any(grepl("idx", printed, fixed = TRUE)))
        testthat::expect_false(any(grepl("dynutillist", printed, fixed = TRUE)))
        testthat::expect_true(inherits(out, "dynutillist"))
      }
    )
  },
  text = "test-dynTools-methods"
)
