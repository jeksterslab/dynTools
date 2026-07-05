#' Delete Initial Rows With Missing Observed Values by ID
#'
#' The function removes leading rows by ID when the observed variables contain
#' missing values. This process is repeated until the first row per ID no
#' longer has missing observed values. Covariates are retained when selecting
#' and sorting the data, but they are not used to determine whether an initial
#' row should be removed.
#'
#' This is a strict helper because the first retained row must be complete on
#' all observed variables. For more flexible trimming, prefer
#' [TrimInitialRowsByID()] with `min_nonmissing`.
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

  if (nrow(data) > 0L) {
    ok <- stats::complete.cases(
      data[
        ,
        observed,
        drop = FALSE
      ]
    )

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
