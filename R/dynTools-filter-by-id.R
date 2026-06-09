#' Filter Dynamic Modeling Data by ID
#'
#' The function removes IDs that do not satisfy minimum data requirements.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param min_rows Non-negative integer.
#'   Minimum number of rows required per ID.
#' @param min_complete Non-negative integer.
#'   Minimum number of complete observed rows required per ID.
#' @param max_prop_missing Numeric.
#'   Maximum allowed proportion of missing values across observed variables.
#' @param allow_initial_na Logical.
#'   If `FALSE`, remove IDs where the initial row contains missing values.
#' @param allow_all_missing Logical.
#'   If `FALSE`, remove IDs where all observed values are missing.
#'
#' @return Returns a data frame.
#'
#' @examples
#' data <- data.frame(
#'   id = rep(1:3, each = 3),
#'   time = rep(1:3, times = 3),
#'   y = c(1, 2, 3, NA, NA, 4, NA, NA, NA)
#' )
#' FilterByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = "y",
#'   min_complete = 2
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
FilterByID <- function(data,
                       id,
                       time,
                       observed,
                       covariates = NULL,
                       min_rows = 2L,
                       min_complete = 2L,
                       max_prop_missing = 1,
                       allow_initial_na = TRUE,
                       allow_all_missing = FALSE) {
  CheckDynData(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates,
    require_unique = FALSE,
    require_numeric_time = TRUE,
    require_numeric_observed = TRUE,
    require_numeric_covariates = FALSE,
    min_rows = 1L
  )

  if (
    !is.numeric(min_rows) ||
      length(min_rows) != 1L ||
      is.na(min_rows) ||
      !is.finite(min_rows) ||
      min_rows < 0L ||
      min_rows != as.integer(min_rows)
  ) {
    stop(
      "`min_rows` must be a non-negative integer.",
      call. = FALSE
    )
  }

  if (
    !is.numeric(min_complete) ||
      length(min_complete) != 1L ||
      is.na(min_complete) ||
      !is.finite(min_complete) ||
      min_complete < 0L ||
      min_complete != as.integer(min_complete)
  ) {
    stop(
      "`min_complete` must be a non-negative integer.",
      call. = FALSE
    )
  }

  if (
    !is.numeric(max_prop_missing) ||
      length(max_prop_missing) != 1L ||
      is.na(max_prop_missing) ||
      !is.finite(max_prop_missing) ||
      max_prop_missing < 0 ||
      max_prop_missing > 1
  ) {
    stop(
      "`max_prop_missing` must be a number between 0 and 1.",
      call. = FALSE
    )
  }

  if (
    !is.logical(allow_initial_na) ||
      length(allow_initial_na) != 1L ||
      is.na(allow_initial_na)
  ) {
    stop(
      "`allow_initial_na` must be `TRUE` or `FALSE`.",
      call. = FALSE
    )
  }

  if (
    !is.logical(allow_all_missing) ||
      length(allow_all_missing) != 1L ||
      is.na(allow_all_missing)
  ) {
    stop(
      "`allow_all_missing` must be `TRUE` or `FALSE`.",
      call. = FALSE
    )
  }

  min_rows <- as.integer(min_rows)
  min_complete <- as.integer(min_complete)

  data <- .DynToolsSelectSort(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates
  )

  if (nrow(data) == 0L) {
    return(data)
  }

  summary <- SummaryByID(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates
  )

  keep <- summary$n_rows >= min_rows &
    summary$n_complete >= min_complete &
    summary$prop_missing <= max_prop_missing

  if (!allow_initial_na) {
    keep <- keep & !summary$initial_na
  }

  if (!allow_all_missing) {
    keep <- keep & !summary$all_missing
  }

  keep_id <- summary[[id]][keep]

  out <- data[
    data[[id]] %in% keep_id, ,
    drop = FALSE
  ]

  rownames(out) <- NULL
  out
}
