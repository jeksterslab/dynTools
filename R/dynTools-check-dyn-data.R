#' Check Dynamic Modeling Data
#'
#' The function checks whether a data frame has the variables and structure
#' required by the dynamic modeling utility functions.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param require_unique Logical.
#'   If `TRUE`, require unique `id`-`time` combinations.
#' @param require_numeric_time Logical.
#'   If `TRUE`, require the time variable to be numeric.
#' @param require_numeric_observed Logical.
#'   If `TRUE`, require observed variables to be numeric.
#' @param require_numeric_covariates Logical.
#'   If `TRUE`, require covariates to be numeric.
#' @param min_rows Positive integer.
#'   Minimum number of rows required per ID.
#'
#' @return Returns `TRUE` invisibly if all checks pass.
#'
#' @examples
#' data <- data.frame(
#'   id = rep(1:2, each = 3),
#'   time = rep(1:3, times = 2),
#'   y1 = rnorm(6),
#'   y2 = rnorm(6)
#' )
#' CheckDynData(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = c("y1", "y2")
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
CheckDynData <- function(data,
                         id,
                         time,
                         observed,
                         covariates = NULL,
                         require_unique = TRUE,
                         require_numeric_time = TRUE,
                         require_numeric_observed = TRUE,
                         require_numeric_covariates = FALSE,
                         min_rows = 2L) {
  if (!is.data.frame(data)) {
    stop(
      "`data` must be a data frame.",
      call. = FALSE
    )
  }

  if (anyDuplicated(names(data))) {
    dup <- unique(
      names(data)[
        duplicated(names(data))
      ]
    )
    stop(
      paste0(
        "`data` must have unique column names. Duplicated: ",
        paste(dup, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  if (
    !is.character(id) ||
      length(id) != 1L ||
      is.na(id) ||
      id == ""
  ) {
    stop(
      "`id` must be a non-empty character string.",
      call. = FALSE
    )
  }

  if (
    !is.character(time) ||
      length(time) != 1L ||
      is.na(time) ||
      time == ""
  ) {
    stop(
      "`time` must be a non-empty character string.",
      call. = FALSE
    )
  }

  if (
    !is.character(observed) ||
      length(observed) == 0L ||
      any(is.na(observed)) ||
      any(observed == "")
  ) {
    stop(
      "`observed` must be a non-empty character vector.",
      call. = FALSE
    )
  }

  if (
    !is.null(covariates) &&
      (
        !is.character(covariates) ||
          any(is.na(covariates)) ||
          any(covariates == "")
      )
  ) {
    stop(
      "`covariates` must be `NULL` or a character vector.",
      call. = FALSE
    )
  }

  if (
    !is.logical(require_unique) ||
      length(require_unique) != 1L ||
      is.na(require_unique)
  ) {
    stop(
      "`require_unique` must be `TRUE` or `FALSE`.",
      call. = FALSE
    )
  }

  if (
    !is.logical(require_numeric_time) ||
      length(require_numeric_time) != 1L ||
      is.na(require_numeric_time)
  ) {
    stop(
      "`require_numeric_time` must be `TRUE` or `FALSE`.",
      call. = FALSE
    )
  }

  if (
    !is.logical(require_numeric_observed) ||
      length(require_numeric_observed) != 1L ||
      is.na(require_numeric_observed)
  ) {
    stop(
      "`require_numeric_observed` must be `TRUE` or `FALSE`.",
      call. = FALSE
    )
  }

  if (
    !is.logical(require_numeric_covariates) ||
      length(require_numeric_covariates) != 1L ||
      is.na(require_numeric_covariates)
  ) {
    stop(
      "`require_numeric_covariates` must be `TRUE` or `FALSE`.",
      call. = FALSE
    )
  }

  if (
    !is.numeric(min_rows) ||
      length(min_rows) != 1L ||
      is.na(min_rows) ||
      min_rows < 1L
  ) {
    stop(
      "`min_rows` must be a positive integer.",
      call. = FALSE
    )
  }

  min_rows <- as.integer(min_rows)

  vars <- c(
    id,
    time,
    observed,
    covariates
  )

  if (anyDuplicated(vars)) {
    dup <- unique(
      vars[
        duplicated(vars)
      ]
    )
    stop(
      paste0(
        "`id`, `time`, `observed`, and `covariates` must identify ",
        "unique variables. Duplicated: ",
        paste(dup, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  missing <- setdiff(
    x = vars,
    y = names(data)
  )

  if (length(missing) > 0L) {
    stop(
      paste0(
        "The following variables are missing from `data`: ",
        paste(missing, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  if (any(is.na(data[[id]]))) {
    stop(
      "`id` must not contain missing values.",
      call. = FALSE
    )
  }

  if (any(is.na(data[[time]]))) {
    stop(
      "`time` must not contain missing values.",
      call. = FALSE
    )
  }

  if (
    require_numeric_time &&
      !is.numeric(data[[time]])
  ) {
    stop(
      "`time` must be numeric when `require_numeric_time = TRUE`.",
      call. = FALSE
    )
  }

  if (require_numeric_observed) {
    bad <- character(0)
    for (j in seq_along(observed)) {
      if (!is.numeric(data[[observed[j]]])) {
        bad <- c(
          bad,
          observed[j]
        )
      }
    }
    if (length(bad) > 0L) {
      stop(
        paste0(
          "Observed variables must be numeric. Non-numeric: ",
          paste(bad, collapse = ", "),
          "."
        ),
        call. = FALSE
      )
    }
  }

  if (
    require_numeric_covariates &&
      !is.null(covariates)
  ) {
    bad <- character(0)
    for (j in seq_along(covariates)) {
      if (!is.numeric(data[[covariates[j]]])) {
        bad <- c(
          bad,
          covariates[j]
        )
      }
    }
    if (length(bad) > 0L) {
      stop(
        paste0(
          "Covariates must be numeric. Non-numeric: ",
          paste(bad, collapse = ", "),
          "."
        ),
        call. = FALSE
      )
    }
  }

  if (require_unique) {
    key <- paste(
      data[[id]],
      data[[time]],
      sep = "\r"
    )

    if (anyDuplicated(key)) {
      stop(
        "`data` must have unique `id`-`time` combinations.",
        call. = FALSE
      )
    }
  }

  if (nrow(data) > 0L) {
    ids <- unique(data[[id]])
    group <- match(
      x = data[[id]],
      table = ids
    )

    n_by_id <- tabulate(
      bin = group,
      nbins = length(ids)
    )

    bad <- ids[
      n_by_id < min_rows
    ]

    if (length(bad) > 0L) {
      stop(
        paste0(
          "Each ID must have at least ",
          min_rows,
          " row(s). IDs with too few rows: ",
          paste(bad, collapse = ", "),
          "."
        ),
        call. = FALSE
      )
    }
  }

  invisible(TRUE)
}
