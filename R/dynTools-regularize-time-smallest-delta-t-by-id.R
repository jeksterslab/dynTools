#' Regularize Time By ID
#'
#' The function computes the smallest positive time difference across IDs and
#' uses that global delta time to regularize the time grid within each ID.
#' For each ID, a complete sequence from the first to the last observed time is
#' created using the global smallest delta time. Rows not present in the
#' original data are inserted with missing values for all non-ID and non-time
#' variables.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param data Data frame.
#' @param id Character string.
#'   ID variable.
#' @param time Character string.
#'   Time variable.
#' @param tol Numeric.
#'   Tolerance used to check whether observed times align with the regularized
#'   time grid.
#'
#' @return Returns a data frame.
#'   The global smallest delta time is stored as the \code{delta_t} attribute.
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 1, 2, 2, 2),
#'   time = c(0, 2, 4, 0, 1, 2),
#'   y = c(1, 2, 3, 10, 11, 12)
#' )
#' RegularizeTimeSmallestDeltaTByID(
#'   data = data,
#'   id = "id",
#'   time = "time"
#' )
#'
#' @export
RegularizeTimeSmallestDeltaTByID <- function(data,
                                             id,
                                             time,
                                             tol = sqrt(.Machine$double.eps)) {
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
  if (!is.numeric(tol) || length(tol) != 1 || is.na(tol) || tol < 0) {
    stop("`tol` must be a non-negative numeric value.")
  }
  if (anyNA(data[[id]])) {
    stop("`id` must not contain missing values.")
  }
  if (anyNA(data[[time]])) {
    stop("`time` must not contain missing values.")
  }
  if (any(duplicated(data[c(id, time)]))) {
    stop("Each `id` and `time` combination must be unique.")
  }

  delta_t <- SmallestDeltaTByID(
    data = data,
    id = id,
    time = time
  )

  data <- data[
    order(
      data[[id]],
      data[[time]]
    ), ,
    drop = FALSE
  ]

  vars <- names(data)
  other <- setdiff(
    x = vars,
    y = c(id, time)
  )

  out <- lapply(
    X = split(
      x = data,
      f = data[[id]],
      drop = TRUE
    ),
    FUN = function(x) {
      start <- min(x[[time]])
      step <- round((x[[time]] - start) / delta_t)

      error <- abs(
        (x[[time]] - start) -
          step * delta_t
      )

      scale <- pmax(
        1,
        abs(x[[time]]),
        abs(start)
      )

      if (any(error > tol * scale)) {
        stop(
          "Observed times do not align with the global smallest `delta_t` grid."
        )
      }

      if (any(duplicated(step))) {
        stop(
          paste(
            "Observed times collapse to duplicate grid positions.",
            "Increase precision or check `time`."
          )
        )
      }

      grid_step <- seq.int(
        from = 0L,
        to = max(step)
      )

      grid <- data.frame(
        x_id = rep(
          x = x[[id]][1],
          times = length(grid_step)
        ),
        x_time = start + delta_t * grid_step
      )

      names(grid) <- c(id, time)

      if (length(other) > 0) {
        grid[other] <- x[
          rep(NA_integer_, length(grid_step)),
          other,
          drop = FALSE
        ]
        grid[step + 1L, other] <- x[
          ,
          other,
          drop = FALSE
        ]
      }

      grid[vars]
    }
  )

  out <- do.call(
    what = rbind,
    args = out
  )

  rownames(out) <- NULL

  attr(out, "delta_t") <- delta_t

  out
}
