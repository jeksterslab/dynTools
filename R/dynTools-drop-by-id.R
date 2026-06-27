#' Drop IDs From a Data Frame
#'
#' The function removes rows belonging to one or more IDs. It is a small
#' convenience wrapper used after ID-level diagnostics identify IDs for
#' exclusion or sensitivity analysis.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param data Data frame.
#' @param id Character string.
#'   Name of the ID variable.
#' @param drop Vector.
#'   ID values to remove. If `NULL` or empty, `data` is returned unchanged.
#'
#' @return Returns a data frame.
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 2, 2, 3, 3),
#'   y = 1:6
#' )
#'
#' DropByID(
#'   data = data,
#'   id = "id",
#'   drop = c(2, 3)
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
DropByID <- function(data,
                     id,
                     drop = NULL) {
  if (!is.data.frame(data)) {
    stop(
      "`data` must be a data frame.",
      call. = FALSE
    )
  }

  if (anyDuplicated(names(data))) {
    stop(
      "`data` must have unique column names.",
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

  if (!id %in% names(data)) {
    stop(
      paste0(
        "`id` is not in `data`: ",
        id,
        "."
      ),
      call. = FALSE
    )
  }

  if (is.null(drop) || length(drop) == 0L) {
    rownames(data) <- NULL
    return(data)
  }

  out <- data[
    !(data[[id]] %in% drop), ,
    drop = FALSE
  ]

  rownames(out) <- NULL
  out
}
