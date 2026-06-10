#' Regularize Time by ID
#'
#' The function inserts rows with missing values so that time follows a regular
#' grid. A global grid uses the same time sequence for every ID. An ID-specific
#' grid uses each ID's own minimum and maximum observed time values.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param delta_t Positive number.
#'   Time interval.
#' @param grid Character string.
#'   If `grid = "global"`, use one time grid from the global minimum to the
#'   global maximum time value. If `grid = "by_id"`, use an ID-specific time
#'   grid from each ID's minimum to maximum time value.
#'
#' @return Returns a data frame.
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 2, 2),
#'   time = c(1, 3, 1, 2),
#'   y = c(10, 12, 20, 21)
#' )
#' data
#'
#' RegularizeTimeByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = "y",
#'   delta_t = 1,
#'   grid = "by_id"
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
RegularizeTimeByID <- function(data,
                               id,
                               time,
                               observed,
                               covariates = NULL,
                               delta_t,
                               grid = c("global", "by_id")) {
  CheckDynData(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates,
    require_unique = TRUE,
    require_numeric_time = TRUE,
    require_numeric_observed = TRUE,
    require_numeric_covariates = FALSE,
    min_rows = 1L
  )

  if (
    !is.numeric(delta_t) ||
      length(delta_t) != 1L ||
      is.na(delta_t) ||
      !is.finite(delta_t) ||
      delta_t <= 0
  ) {
    stop(
      "`delta_t` must be a positive finite number.",
      call. = FALSE
    )
  }

  grid <- match.arg(grid)

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

  key_data <- paste(
    data[[id]],
    data[[time]],
    sep = "\r"
  )

  if (anyDuplicated(key_data)) {
    stop(
      "`RegularizeTimeByID()` requires unique `id`-`time` combinations.",
      call. = FALSE
    )
  }

  ids <- unique(data[[id]])

  if (grid == "global") {
    times <- data[[time]]

    new_times <- sort(
      unique(
        c(
          seq(
            from = min(times),
            to = max(times),
            by = delta_t
          ),
          times
        )
      )
    )

    n_id <- length(ids)
    n_time <- length(new_times)
    n_out <- n_id * n_time

    out <- data[
      rep.int(
        x = NA_integer_,
        times = n_out
      ), ,
      drop = FALSE
    ]

    out[[id]] <- rep(
      x = ids,
      each = n_time
    )

    out[[time]] <- rep(
      x = new_times,
      times = n_id
    )
  } else {
    run <- rle(data[[id]])
    end <- cumsum(run$lengths)
    start <- end - run$lengths + 1L

    out_list <- vector(
      mode = "list",
      length = length(start)
    )

    for (j in seq_along(start)) {
      index <- seq.int(
        from = start[j],
        to = end[j]
      )

      times <- data[[time]][index]

      new_times <- sort(
        unique(
          c(
            seq(
              from = min(times),
              to = max(times),
              by = delta_t
            ),
            times
          )
        )
      )

      out_j <- data[
        rep.int(
          x = NA_integer_,
          times = length(new_times)
        ), ,
        drop = FALSE
      ]

      out_j[[id]] <- rep(
        x = data[[id]][start[j]],
        times = length(new_times)
      )

      out_j[[time]] <- new_times

      out_list[[j]] <- out_j
    }

    out <- do.call(
      what = rbind,
      args = out_list
    )
  }

  key_out <- paste(
    out[[id]],
    out[[time]],
    sep = "\r"
  )

  pos <- match(
    x = key_data,
    table = key_out
  )

  out[
    pos,
    names(data)
  ] <- data

  rownames(out) <- NULL
  out
}
