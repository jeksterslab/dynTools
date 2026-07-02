#' Delete Rows With All Observed Variables Missing
#'
#' The function removes rows where all observed variables are missing.
#'
#' Covariates are retained in the returned data, but they are not used to decide
#' whether a row should be deleted.
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
#'   y1 = c(NA, NA, 3, 4, 5, NA, 11, 12, 13, 14),
#'   y2 = c(NA, 2, 3, 4, 5, NA, 11, 12, 13, 14),
#'   y3 = c(NA, NA, 3, 4, 5, NA, 11, 12, 13, 14)
#' )
#' data
#'
#' DeleteObservedAllNA(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = paste0("y", 1:3)
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
DeleteObservedAllNA <- function(data,
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
    keep <- rowSums(
      x = !is.na(data[, observed, drop = FALSE])
    ) > 0L

    data <- data[
      keep, ,
      drop = FALSE
    ]
  }

  rownames(data) <- NULL
  data
}
