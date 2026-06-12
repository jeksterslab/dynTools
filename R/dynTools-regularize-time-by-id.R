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

  time_tolerance <- max(
    sqrt(.Machine$double.eps) * max(1, abs(delta_t)),
    1000 * .Machine$double.eps * max(
      1,
      abs(data[[time]]),
      na.rm = TRUE
    )
  )

  make_grid <- function(from, to, by, tolerance) {
    n_steps <- floor(
      x = (to - from) / by + tolerance / by
    )

    out <- from + seq.int(
      from = 0L,
      to = n_steps
    ) * by

    out[
      out <= to + tolerance
    ]
  }

  canonicalize_time <- function(x, origin, by, tolerance) {
    k <- round(
      x = (x - origin) / by
    )

    x_grid <- origin + k * by

    near_grid <- abs(x - x_grid) <= tolerance

    x[near_grid] <- x_grid[near_grid]

    x
  }

  make_key <- function(id_value, time_value) {
    paste(
      as.character(id_value),
      sprintf("%.17g", time_value),
      sep = "\r"
    )
  }

  ids <- unique(data[[id]])

  time_match <- data[[time]]

  if (grid == "global") {
    times <- data[[time]]
    origin <- min(times)
    endpoint <- max(times)

    grid_times <- make_grid(
      from = origin,
      to = endpoint,
      by = delta_t,
      tolerance = time_tolerance
    )

    time_match <- canonicalize_time(
      x = times,
      origin = origin,
      by = delta_t,
      tolerance = time_tolerance
    )

    new_times <- sort(
      unique(
        c(
          grid_times,
          time_match
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
      origin <- min(times)
      endpoint <- max(times)

      grid_times <- make_grid(
        from = origin,
        to = endpoint,
        by = delta_t,
        tolerance = time_tolerance
      )

      time_match[index] <- canonicalize_time(
        x = times,
        origin = origin,
        by = delta_t,
        tolerance = time_tolerance
      )

      new_times <- sort(
        unique(
          c(
            grid_times,
            time_match[index]
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

  key_data <- make_key(
    id_value = data[[id]],
    time_value = time_match
  )

  if (anyDuplicated(key_data)) {
    stop(
      paste(
        "`RegularizeTimeByID()` found duplicate or near-duplicate",
        "`id`-`time` combinations after applying the `delta_t` grid."
      ),
      call. = FALSE
    )
  }

  key_out <- make_key(
    id_value = out[[id]],
    time_value = out[[time]]
  )

  if (anyDuplicated(key_out)) {
    stop(
      "`RegularizeTimeByID()` created duplicate `id`-`time` rows.",
      call. = FALSE
    )
  }

  pos <- match(
    x = key_data,
    table = key_out
  )

  value_vars <- setdiff(
    x = names(data),
    y = c(
      id,
      time
    )
  )

  out[
    pos,
    value_vars
  ] <- data[
    ,
    value_vars,
    drop = FALSE
  ]

  rownames(out) <- NULL
  out
}
