## ---- test-dynTools-dyn-utils-select-sort-dot
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    .DynToolsSelectSort <- getFromNamespace(
      ".DynToolsSelectSort",
      "dynTools"
    )

    testthat::test_that(
      paste(
        text,
        ".DynToolsSelectSort",
        "selects requested variables and sorts rows"
      ),
      {
        data <- data.frame(
          extra = letters[1:6],
          y = c(10, 11, 20, 21, 30, 31),
          x = c(1, 2, 3, 4, 5, 6),
          wave = c(2, 1, 2, 1, 1, 2),
          id = c(2, 2, 1, 1, 3, 3),
          age = c(20, 20, 30, 30, 40, 40)
        )

        out <- .DynToolsSelectSort(
          data = data,
          id = "id",
          time = "wave",
          observed = c("y", "x"),
          covariates = "age"
        )

        expected <- data.frame(
          id = c(1, 1, 2, 2, 3, 3),
          wave = c(1, 2, 1, 2, 1, 2),
          y = c(21, 20, 11, 10, 30, 31),
          x = c(4, 3, 2, 1, 5, 6),
          age = c(30, 30, 20, 20, 40, 40)
        )

        testthat::expect_identical(out, expected)
        testthat::expect_identical(
          rownames(out),
          as.character(seq_len(nrow(out)))
        )
        testthat::expect_false("extra" %in% names(out))
      }
    )

    testthat::test_that(
      paste(
        text,
        ".DynToolsSelectSort",
        "works with covariates = NULL"
      ),
      {
        data <- data.frame(
          id = c("b", "a", "b", "a"),
          time = c(2L, 2L, 1L, 1L),
          y = 1:4,
          z = 5:8
        )

        out <- .DynToolsSelectSort(
          data = data,
          id = "id",
          time = "time",
          observed = "y"
        )

        expected <- data.frame(
          id = c("a", "a", "b", "b"),
          time = c(1L, 2L, 1L, 2L),
          y = c(4L, 2L, 3L, 1L)
        )

        testthat::expect_identical(out, expected)
      }
    )

    testthat::test_that(
      paste(
        text,
        ".DynToolsSelectSort",
        "removes duplicated variable requests"
      ),
      {
        data <- data.frame(
          id = c(1L, 1L),
          time = c(2L, 1L),
          y = c(2, 1)
        )

        out <- .DynToolsSelectSort(
          data = data,
          id = "id",
          time = "time",
          observed = c("y", "y"),
          covariates = c("y", NULL)
        )

        testthat::expect_identical(names(out), c("id", "time", "y"))
        testthat::expect_identical(out$time, c(1L, 2L))
      }
    )

    testthat::test_that(
      paste(
        text,
        ".DynToolsSelectSort",
        "errors when requested variables are absent"
      ),
      {
        data <- data.frame(
          id = 1L,
          time = 1L,
          y = 1
        )

        testthat::expect_error(
          .DynToolsSelectSort(
            data = data,
            id = "id",
            time = "time",
            observed = "missing"
          ),
          regexp = "undefined columns selected"
        )
      }
    )
  },
  text = "test-dynTools-dyn-utils-select-sort-dot"
)
