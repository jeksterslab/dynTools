## ---- test-dynTools-plot-by-id
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    testthat::test_that(
      paste(
        text,
        "coverage"
      ),
      {
        testthat::skip_on_cran()

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

        PlotByID(
          data = data,
          id = "id",
          time = "time",
          observed = paste0("y", 1:3),
          ask = FALSE
        )

        PlotByID(
          data = data,
          id = "id",
          time = "time",
          observed = paste0("y", 1:3),
          ids = 1:3,
          times = c(1, 3),
          legend = TRUE,
          ask = FALSE
        )
      }
    )
  },
  text = "test-dynTools-plot-by-id"
)
