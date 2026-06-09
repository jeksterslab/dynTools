## ---- test-dynTools-dyn-utils-use-parallel-dot
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    .DynToolsUseParallel <- getFromNamespace(
      ".DynToolsUseParallel",
      "dynTools"
    )

    testthat::test_that(
      paste(
        text,
        ".DynToolsUseParallel",
        "returns TRUE only when parallelism is useful"
      ),
      {
        testthat::expect_false(
          .DynToolsUseParallel(ncores = NULL, n_tasks = 2L)
        )
        testthat::expect_false(
          .DynToolsUseParallel(ncores = 1L, n_tasks = 2L)
        )
        testthat::expect_false(
          .DynToolsUseParallel(ncores = 2L, n_tasks = 1L)
        )
        testthat::expect_false(
          .DynToolsUseParallel(ncores = NA_integer_, n_tasks = 2L)
        )
        testthat::expect_true(
          .DynToolsUseParallel(ncores = 2L, n_tasks = 2L)
        )
        testthat::expect_true(
          .DynToolsUseParallel(ncores = c(2L, 1L), n_tasks = 3L)
        )
      }
    )
  },
  text = "test-dynTools-dyn-utils-use-parallel-dot"
)
