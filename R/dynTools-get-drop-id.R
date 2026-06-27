#' Get Sensitivity-Drop IDs From Diagnostics
#'
#' The function extracts IDs marked as sensitivity-drop candidates by
#' [FlagDiagnosticsByID()].
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param x Data frame returned by [FlagDiagnosticsByID()].
#' @param flagged_only Logical.
#' If `TRUE`, return IDs marked as sensitivity-drop candidates. If `FALSE`,
#' return all flagged IDs.
#'
#' @return Returns a vector of IDs.
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 1, 2, 2, 2),
#'   time = c(1, 2, 3, 1, 2, 3),
#'   y1 = c(1, NA, 3, 1, 1, 1),
#'   y2 = c(NA, NA, 4, 2, 2, 2)
#' )
#'
#' diagnostics <- DiagnosticsByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = c("y1", "y2")
#' )
#'
#' flagged <- FlagDiagnosticsByID(
#'   x = diagnostics,
#'   min_observed_rows = 3,
#'   min_sd = 0.05
#' )
#'
#' GetDropID(flagged)
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
GetDropID <- function(x,
                      flagged_only = TRUE) {
  if (!is.data.frame(x)) {
    stop(
      "`x` must be a data frame returned by `FlagDiagnosticsByID()`.",
      call. = FALSE
    )
  }

  if (!"id" %in% names(x)) {
    stop(
      "`x` must contain an `id` column.",
      call. = FALSE
    )
  }

  if (
    !is.logical(flagged_only) ||
      length(flagged_only) != 1L ||
      is.na(flagged_only)
  ) {
    stop(
      "`flagged_only` must be `TRUE` or `FALSE`.",
      call. = FALSE
    )
  }

  if (flagged_only) {
    if (!"drop_sensitivity_candidate" %in% names(x)) {
      stop(
        "`x` must contain a `drop_sensitivity_candidate` column.",
        call. = FALSE
      )
    }
    return(x$id[x$drop_sensitivity_candidate])
  }

  if (!"flag_any" %in% names(x)) {
    stop(
      "`x` must contain a `flag_any` column.",
      call. = FALSE
    )
  }

  x$id[x$flag_any]
}
