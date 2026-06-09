#' Create Lagged Variables by ID
#'
#' The function creates lagged observed variables within ID.
#' Lagged values never cross ID boundaries.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param lags Positive integer vector.
#'   Lags to create.
#' @param prefix Character string.
#'   Prefix for the lagged variable names.
#'
#' @return Returns a data frame.
#'
#' @examples
#' data <- data.frame(
#'   id = rep(1:2, each = 3),
#'   time = rep(1:3, times = 2),
#'   y1 = rnorm(6),
#'   y2 = rnorm(6)
#' )
#' LagByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = c("y1", "y2"),
#'   lags = 1
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
LagByID <- function(data,
                    id,
                    time,
                    observed,
                    covariates = NULL,
                    lags = 1L,
                    prefix = "lag") {
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
    !is.numeric(lags) ||
      length(lags) == 0L ||
      any(is.na(lags)) ||
      any(!is.finite(lags)) ||
      any(lags < 1L) ||
      any(lags != as.integer(lags))
  ) {
    stop(
      "`lags` must be a positive integer vector.",
      call. = FALSE
    )
  }

  lags <- sort(
    unique(
      as.integer(lags)
    )
  )

  if (
    !is.character(prefix) ||
      length(prefix) != 1L ||
      is.na(prefix)
  ) {
    stop(
      "`prefix` must be a character string.",
      call. = FALSE
    )
  }

  new_names <- character(0)
  for (lag in lags) {
    new_names <- c(
      new_names,
      paste0(
        prefix,
        lag,
        "_",
        observed
      )
    )
  }

  collision <- intersect(
    x = new_names,
    y = names(data)
  )

  if (length(collision) > 0L) {
    stop(
      paste0(
        "Lagged variable names already exist in `data`: ",
        paste(collision, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  data <- .DynToolsSelectSort(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates
  )

  if (nrow(data) == 0L) {
    for (new_name in new_names) {
      data[[new_name]] <- numeric(0)
    }
    return(data)
  }

  run <- rle(data[[id]])
  end <- cumsum(run$lengths)
  start <- end - run$lengths + 1L

  for (lag in lags) {
    for (var in observed) {
      new_name <- paste0(
        prefix,
        lag,
        "_",
        var
      )

      lagged <- data[[var]][
        rep(
          x = NA_integer_,
          times = nrow(data)
        )
      ]

      for (j in seq_along(start)) {
        index <- seq.int(
          from = start[j],
          to = end[j]
        )

        n_index <- length(index)

        if (n_index > lag) {
          lagged[
            index[
              seq.int(
                from = lag + 1L,
                to = n_index
              )
            ]
          ] <- data[[var]][
            index[
              seq.int(
                from = 1L,
                to = n_index - lag
              )
            ]
          ]
        }
      }

      data[[new_name]] <- lagged
    }
  }

  rownames(data) <- NULL
  data
}
