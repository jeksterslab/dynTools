#' Regularize Time by ID
#'
#' The function inserts rows with missing values so that time follows a regular
#' grid. A global grid uses the same time sequence for every ID. An ID-specific
#' grid uses each ID's own minimum and maximum observed time values.
#' If `method = "preserve"`, the function completes the regular grid while
#' retaining empirical off-grid time values. If `method = "snap"`, empirical
#' time values are snapped to the nearest grid point and the returned data use
#' only grid time values.
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
#' @param method Character string.
#'   If `method = "preserve"`, complete the regular grid but preserve observed
#'   off-grid time values. If `method = "snap"`, snap observed time values to
#'   the nearest grid point so the output contains only regular grid times.
#'   When multiple rows for the same ID snap to the same grid point, the row
#'   closest to the grid point is kept; ties are broken by the largest number
#'   of non-missing observed/covariate values and then by original order.
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
#' RegularizeTimeByID(
#'   data = data.frame(
#'     id = c(1, 1),
#'     time = c(1.0, 1.7),
#'     y = c(10, 17)
#'   ),
#'   id = "id",
#'   time = "time",
#'   observed = "y",
#'   delta_t = 0.5,
#'   grid = "by_id",
#'   method = "snap"
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
                               grid = c("global", "by_id"),
                               method = c("preserve", "snap")) {
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
  method <- match.arg(method)

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
    if (to < from - tolerance) {
      return(numeric(0))
    }

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

  snap_time <- function(x, origin, by) {
    k <- round(
      x = (x - origin) / by
    )

    origin + k * by
  }

  canonicalize_time <- function(x, origin, by, tolerance) {
    x_grid <- snap_time(
      x = x,
      origin = origin,
      by = by
    )

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

  complete_vars <- c(
    observed,
    covariates
  )

  complete_count <- rowSums(
    x = !is.na(
      data[
        ,
        complete_vars,
        drop = FALSE
      ]
    )
  )

  ids <- unique(data[[id]])
  original_index <- seq_len(nrow(data))
  time_match <- data[[time]]
  snap_error <- rep(
    x = 0,
    times = nrow(data)
  )

  if (grid == "global") {
    times <- data[[time]]
    origin <- min(times)
    endpoint <- max(times)

    if (method == "snap") {
      snapped <- snap_time(
        x = times,
        origin = origin,
        by = delta_t
      )

      time_match <- snapped
      snap_error <- abs(times - snapped)
      endpoint <- max(snapped)

      new_times <- make_grid(
        from = origin,
        to = endpoint,
        by = delta_t,
        tolerance = time_tolerance
      )
    } else {
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
    }

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

      if (method == "snap") {
        snapped <- snap_time(
          x = times,
          origin = origin,
          by = delta_t
        )

        time_match[index] <- snapped
        snap_error[index] <- abs(times - snapped)
        endpoint <- max(snapped)

        new_times <- make_grid(
          from = origin,
          to = endpoint,
          by = delta_t,
          tolerance = time_tolerance
        )
      } else {
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
      }

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
    if (method == "preserve") {
      stop(
        paste(
          "`RegularizeTimeByID()` found duplicate or near-duplicate",
          "`id`-`time` combinations after applying the `delta_t` grid."
        ),
        call. = FALSE
      )
    }

    ord <- order(
      key_data,
      snap_error,
      -complete_count,
      original_index
    )

    data <- data[
      ord, ,
      drop = FALSE
    ]

    key_data <- key_data[ord]
    time_match <- time_match[ord]

    keep <- !duplicated(key_data)

    data <- data[
      keep, ,
      drop = FALSE
    ]

    key_data <- key_data[keep]
    time_match <- time_match[keep]
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

  if (any(is.na(pos))) {
    stop(
      "`RegularizeTimeByID()` could not match all observations to the time grid.",
      call. = FALSE
    )
  }

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
