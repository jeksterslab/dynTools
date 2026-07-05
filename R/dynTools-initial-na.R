#' Check for Missing Observed Values in Initial Row by ID
#'
#' The function checks whether the initial row for each ID has missing values
#' in the observed variables. Covariates are retained when selecting and
#' sorting the data, but they are not used to determine whether the initial
#' row is missing.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams InsertNA
#'
#' @return Returns a vector of ID values
#'   where the initial row has any missing observed value.
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
#' InitialNA(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = paste0("y", 1:3)
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
InitialNA <- function(data,
                      id,
                      time,
                      observed,
                      covariates = NULL) {
  CheckDynData(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates,
    require_unique = FALSE,
    require_numeric_time = FALSE,
    require_numeric_observed = FALSE,
    require_numeric_covariates = FALSE,
    min_rows = 1L
  )

  data <- .DynToolsSelectSort(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates
  )

  if (nrow(data) == 0L) {
    data[[id]][0]
  } else {
    run <- rle(data[[id]])
    start <- cumsum(run$lengths) - run$lengths + 1L

    first_rows <- data[
      start, ,
      drop = FALSE
    ]

    first_rows[
      !stats::complete.cases(
        first_rows[
          ,
          observed,
          drop = FALSE
        ]
      ),
      id
    ]
  }
}
