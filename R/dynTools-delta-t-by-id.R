#' Summarize Time Intervals by ID
#'
#' The function returns a diagnostic table describing the spacing of the time
#' variable within each ID.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param data Data frame.
#'   A data frame object.
#' @param id Character string.
#'   A character string of the name of the ID variable in the data.
#' @param time Character string.
#'   A character string of the name of the TIME variable in the data.
#' @param observed Character vector.
#'   Optional vector of character strings of the names of the observed
#'   variables in the data.
#' @param covariates Character vector.
#'   Optional vector of character strings of the names of the covariates in
#'   the data.
#' @param tolerance Numeric.
#'   Tolerance used to determine whether the time intervals are regular.
#'
#' @return Returns a data frame with one row per ID.
#'
#' @examples
#' data <- data.frame(
#'   id = rep(1:2, each = 3),
#'   time = c(1, 2, 3, 1, 3, 4),
#'   y = rnorm(6)
#' )
#' data
#'
#' DeltaTByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = "y"
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
DeltaTByID <- function(data,
                       id,
                       time,
                       observed = NULL,
                       covariates = NULL,
                       tolerance = sqrt(.Machine$double.eps)) {
  if (!is.data.frame(data)) {
    stop(
      "`data` must be a data frame.",
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
    !is.numeric(tolerance) ||
      length(tolerance) != 1L ||
      is.na(tolerance) ||
      !is.finite(tolerance) ||
      tolerance < 0
  ) {
    stop(
      "`tolerance` must be a non-negative finite number.",
      call. = FALSE
    )
  }

  if (is.null(observed)) {
    missing <- setdiff(
      x = c(id, time),
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

    if (!is.numeric(data[[time]])) {
      stop(
        "`time` must be numeric.",
        call. = FALSE
      )
    }

    data <- data[
      ,
      c(id, time),
      drop = FALSE
    ]

    data <- data[
      order(
        data[[id]],
        data[[time]]
      ), ,
      drop = FALSE
    ]

    rownames(data) <- NULL
  } else {
    CheckDynData(
      data = data,
      id = id,
      time = time,
      observed = observed,
      covariates = covariates,
      require_unique = FALSE,
      require_numeric_time = TRUE,
      require_numeric_observed = FALSE,
      require_numeric_covariates = FALSE,
      min_rows = 1L
    )

    data <- .DynToolsSelectSort(
      data = data,
      id = id,
      time = time,
      observed = observed,
      covariates = covariates
    )
  }

  if (nrow(data) == 0L) {
    out <- data.frame(
      id = data[[id]][0],
      n_rows = integer(0),
      n_intervals = integer(0),
      time_min = data[[time]][0],
      time_max = data[[time]][0],
      min_delta_t = numeric(0),
      median_delta_t = numeric(0),
      max_delta_t = numeric(0),
      n_unique_delta_t = integer(0),
      regular = logical(0),
      stringsAsFactors = FALSE
    )

    names(out)[1] <- id
    return(out)
  }

  run <- rle(data[[id]])
  end <- cumsum(run$lengths)
  start <- end - run$lengths + 1L

  out <- data.frame(
    id = data[[id]][start],
    n_rows = run$lengths,
    n_intervals = pmax(run$lengths - 1L, 0L),
    time_min = data[[time]][start],
    time_max = data[[time]][start],
    min_delta_t = rep(NA_real_, length(start)),
    median_delta_t = rep(NA_real_, length(start)),
    max_delta_t = rep(NA_real_, length(start)),
    n_unique_delta_t = integer(length(start)),
    regular = logical(length(start)),
    stringsAsFactors = FALSE
  )

  names(out)[1] <- id

  for (j in seq_along(start)) {
    index <- seq.int(
      from = start[j],
      to = end[j]
    )

    times <- data[[time]][index]
    delta_t <- diff(times)

    out$time_min[j] <- min(times)
    out$time_max[j] <- max(times)

    if (length(delta_t) == 0L) {
      out$n_unique_delta_t[j] <- 0L
      out$regular[j] <- TRUE
    } else {
      out$min_delta_t[j] <- min(delta_t)
      out$median_delta_t[j] <- stats::median(delta_t)
      out$max_delta_t[j] <- max(delta_t)
      out$n_unique_delta_t[j] <- length(
        unique(delta_t)
      )
      out$regular[j] <- all(
        abs(delta_t - delta_t[1]) <= tolerance
      )
    }
  }

  rownames(out) <- NULL
  out
}
