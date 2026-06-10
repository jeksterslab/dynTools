#' Summarize Dynamic Modeling Data by ID
#'
#' The function returns a diagnostic table with one row per ID.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#'
#' @return Returns a data frame with one row per ID.
#'
#' @examples
#' data <- data.frame(
#'   id = rep(1:2, each = 3),
#'   time = rep(1:3, times = 2),
#'   y1 = c(1, NA, 3, 4, 5, 6),
#'   y2 = c(1, 2, 3, NA, NA, NA)
#' )
#' data
#'
#' SummaryByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = c("y1", "y2")
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
SummaryByID <- function(data,
                        id,
                        time,
                        observed,
                        covariates = NULL) {
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

  data <- .DynToolsSelectSort(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates
  )

  if (nrow(data) == 0L) {
    out <- data.frame(
      id = data[[id]][0],
      n_rows = integer(0),
      n_complete = integer(0),
      n_missing = integer(0),
      prop_missing = numeric(0),
      time_min = data[[time]][0],
      time_max = data[[time]][0],
      n_unique_time = integer(0),
      n_duplicate_time = integer(0),
      initial_na = logical(0),
      all_missing = logical(0)
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
    n_complete = integer(length(start)),
    n_missing = integer(length(start)),
    prop_missing = numeric(length(start)),
    time_min = data[[time]][start],
    time_max = data[[time]][start],
    n_unique_time = integer(length(start)),
    n_duplicate_time = integer(length(start)),
    initial_na = logical(length(start)),
    all_missing = logical(length(start))
  )

  names(out)[1] <- id

  initial_vars <- c(
    observed,
    covariates
  )

  for (j in seq_along(start)) {
    index <- seq.int(
      from = start[j],
      to = end[j]
    )

    x <- data[
      index,
      observed,
      drop = FALSE
    ]

    n_values <- length(index) * length(observed)
    n_missing <- sum(is.na(x))

    out$n_complete[j] <- sum(
      stats::complete.cases(x)
    )

    out$n_missing[j] <- n_missing

    out$prop_missing[j] <- n_missing / n_values

    out$time_min[j] <- min(data[[time]][index])

    out$time_max[j] <- max(data[[time]][index])

    out$n_unique_time[j] <- length(
      unique(
        data[[time]][index]
      )
    )

    out$n_duplicate_time[j] <- length(index) - out$n_unique_time[j]

    out$initial_na[j] <- !stats::complete.cases(
      data[
        index[1],
        initial_vars,
        drop = FALSE
      ]
    )

    out$all_missing[j] <- all(
      is.na(x)
    )
  }

  rownames(out) <- NULL
  out
}
