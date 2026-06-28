#' Remove Rows With Too Few Observed Values
#'
#' The function removes rows with fewer than a requested number of non-missing
#' observed variables. This is useful after regularizing or padding intensive
#' longitudinal data, where many rows may contain no observed measurements but
#' retain an ID and time value.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param min_nonmissing Positive integer.
#' Minimum number of non-missing observed variables required to retain a row.
#' @param min_rows_by_id `NULL` or positive integer.
#' If not `NULL`, IDs with fewer than `min_rows_by_id` retained rows are removed
#' after row filtering.
#'
#' @return Returns a data frame.
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 1, 2, 2),
#'   time = c(1, 2, 3, 1, 2),
#'   y1 = c(1, NA, 3, NA, 2),
#'   y2 = c(NA, NA, 4, NA, 3)
#' )
#'
#' FilterObservedRows(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = c("y1", "y2")
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
FilterObservedRows <- function(data,
                               id,
                               time,
                               observed,
                               covariates = NULL,
                               min_nonmissing = 1L,
                               min_rows_by_id = NULL) {
  CheckDynData(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates,
    require_unique = FALSE,
    require_numeric_time = FALSE,
    require_numeric_observed = TRUE,
    require_numeric_covariates = FALSE,
    min_rows = 1L
  )

  if (
    !is.numeric(min_nonmissing) ||
      length(min_nonmissing) != 1L ||
      is.na(min_nonmissing) ||
      !is.finite(min_nonmissing) ||
      min_nonmissing < 1L ||
      min_nonmissing != as.integer(min_nonmissing)
  ) {
    stop(
      "`min_nonmissing` must be a positive integer.",
      call. = FALSE
    )
  }

  min_nonmissing <- as.integer(min_nonmissing)

  if (min_nonmissing > length(observed)) {
    stop(
      "`min_nonmissing` must be less than or equal to `length(observed)`.",
      call. = FALSE
    )
  }

  if (!is.null(min_rows_by_id)) {
    if (
      !is.numeric(min_rows_by_id) ||
        length(min_rows_by_id) != 1L ||
        is.na(min_rows_by_id) ||
        !is.finite(min_rows_by_id) ||
        min_rows_by_id < 1L ||
        min_rows_by_id != as.integer(min_rows_by_id)
    ) {
      stop(
        "`min_rows_by_id` must be `NULL` or a positive integer.",
        call. = FALSE
      )
    }
    min_rows_by_id <- as.integer(min_rows_by_id)
  }

  keep <- rowSums(!is.na(data[observed])) >= min_nonmissing

  data <- data[keep, , drop = FALSE]

  if (!is.null(min_rows_by_id) && nrow(data) > 0L) {
    n_by_id <- table(data[[id]])
    keep_id <- names(n_by_id)[n_by_id >= min_rows_by_id]
    data <- data[data[[id]] %in% keep_id, , drop = FALSE]
  }

  data <- data[order(data[[id]], data[[time]]), , drop = FALSE]
  rownames(data) <- NULL
  data
}
