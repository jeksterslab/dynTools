#' Smallest Global Delta Time By ID
#'
#' The function computes the smallest positive time difference between
#' consecutive unique time points within ID, then takes the minimum across IDs.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param data Data frame.
#' @param id Character string.
#'   ID variable.
#' @param time Character string.
#'   Time variable.
#'
#' @return Returns a numeric value.
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 1, 2, 2, 2),
#'   time = c(0, 2, 4, 0, 1, 2),
#'   y = c(1, 2, 3, 10, 11, 12)
#' )
#' SmallestDeltaTByID(
#'   data = data,
#'   id = "id",
#'   time = "time"
#' )
#'
#' @export
SmallestDeltaTByID <- function(data, id, time) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.")
  }
  if (!is.character(id) || length(id) != 1) {
    stop("`id` must be a character string.")
  }
  if (!is.character(time) || length(time) != 1) {
    stop("`time` must be a character string.")
  }
  if (!id %in% names(data)) {
    stop("`id` must be in `data`.")
  }
  if (!time %in% names(data)) {
    stop("`time` must be in `data`.")
  }
  if (!is.numeric(data[[time]])) {
    stop("`time` must be numeric.")
  }
  if (anyNA(data[[id]])) {
    stop("`id` must not contain missing values.")
  }
  if (anyNA(data[[time]])) {
    stop("`time` must not contain missing values.")
  }

  delta_t <- unlist(
    x = lapply(
      X = split(
        x = data[[time]],
        f = data[[id]]
      ),
      FUN = function(x) {
        x <- sort(unique(x))
        if (length(x) < 2) {
          return(numeric(0))
        }
        diff(x)
      }
    ),
    use.names = FALSE
  )

  delta_t <- delta_t[
    is.finite(delta_t) &
      delta_t > 0
  ]

  if (length(delta_t) == 0) {
    stop("Could not compute a positive `delta_t`.")
  }

  min(delta_t)
}
