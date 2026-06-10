#' Delete for NAs in Initial Row By ID
#'
#' The function removes initial rows by ID if they contain missing values.
#' This process is repeated until the first row per ID no longer has missing
#' observations.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#'
#' @return Returns a data frame.
#'
#' @examples
#' data <- data.frame(
#'   id = rep(1:2, each = 5),
#'   time = rep(1:5, times = 2),
#'   y1 = c(NA, NA, 3, 4, 5, 10, 11, 12, 13, 14),
#'   y2 = c(NA, 2, 3, 4, 5, 10, 11, 12, 13, 14),
#'   y3 = c(1, NA, 3, 4, 5, 10, 11, 12, 13, 14)
#' )
#' data
#'
#' DeleteInitialNA(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = paste0("y", 1:3)
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
DeleteInitialNA <- function(data,
                            id,
                            time,
                            observed,
                            covariates = NULL) {
  data <- .DynToolsSelectSort(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates
  )

  if (nrow(data) > 0L) {
    ok <- stats::complete.cases(data)

    if (!all(ok)) {
      run <- rle(data[[id]])
      end <- cumsum(run$lengths)
      start <- end - run$lengths + 1L

      keep <- lapply(
        X = seq_along(start),
        FUN = .DeleteInitialNAKeepIndex,
        start = start,
        end = end,
        ok = ok
      )

      keep <- unlist(
        x = keep,
        use.names = FALSE
      )

      data <- data[
        keep, ,
        drop = FALSE
      ]
    }
  }

  rownames(data) <- NULL
  data
}
