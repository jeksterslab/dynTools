#' Detrend Observed Variables by ID
#'
#' The function removes polynomial time trends from observed variables within
#' each ID. Missing observed values are ignored when estimating the trend and
#' remain missing in the residualized variables.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param degree Non-negative integer.
#'   Degree of the polynomial trend. Use `degree = 0` for mean centering by ID.
#' @param replace Logical.
#'   If `TRUE`, replace observed variables with residualized variables. If
#'   `FALSE`, append residualized variables to the data frame.
#' @param prefix Character string.
#'   Prefix for residualized variables when `replace = FALSE`.
#'
#' @return Returns a data frame.
#'
#' @examples
#' data <- data.frame(
#'   id = rep(1:2, each = 4),
#'   time = rep(1:4, times = 2),
#'   y = rep(1:4, times = 2)
#' )
#' data
#'
#' DetrendByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = "y",
#'   degree = 1
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
DetrendByID <- function(data,
                        id,
                        time,
                        observed,
                        covariates = NULL,
                        degree = 1L,
                        replace = FALSE,
                        prefix = "detrend") {
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

  if (
    !is.numeric(degree) ||
      length(degree) != 1L ||
      is.na(degree) ||
      !is.finite(degree) ||
      degree < 0L ||
      degree != as.integer(degree)
  ) {
    stop(
      "`degree` must be a non-negative integer.",
      call. = FALSE
    )
  }

  if (
    !is.logical(replace) ||
      length(replace) != 1L ||
      is.na(replace)
  ) {
    stop(
      "`replace` must be `TRUE` or `FALSE`.",
      call. = FALSE
    )
  }

  if (
    !is.character(prefix) ||
      length(prefix) != 1L ||
      is.na(prefix) ||
      prefix == ""
  ) {
    stop(
      "`prefix` must be a non-empty character string.",
      call. = FALSE
    )
  }

  degree <- as.integer(degree)

  if (!replace) {
    new_names <- paste0(
      prefix,
      "_",
      observed
    )

    collision <- intersect(
      x = new_names,
      y = names(data)
    )

    if (length(collision) > 0L) {
      stop(
        paste0(
          "Residualized variable names already exist in `data`: ",
          paste(collision, collapse = ", "),
          "."
        ),
        call. = FALSE
      )
    }
  }

  data <- .DynToolsSelectSort(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates
  )

  if (nrow(data) == 0L) {
    if (!replace) {
      for (var in observed) {
        data[[paste0(prefix, "_", var)]] <- numeric(0)
      }
    }
    return(data)
  }

  run <- rle(data[[id]])
  end <- cumsum(run$lengths)
  start <- end - run$lengths + 1L

  for (var in observed) {
    residualized <- rep(
      x = NA_real_,
      times = nrow(data)
    )

    for (j in seq_along(start)) {
      index <- seq.int(
        from = start[j],
        to = end[j]
      )

      y <- data[[var]][index]
      times <- data[[time]][index]

      ok <- !is.na(y) & !is.na(times)
      n_ok <- sum(ok)

      if (n_ok > degree) {
        if (degree == 0L) {
          x <- matrix(
            data = 1,
            nrow = n_ok,
            ncol = 1L
          )
        } else {
          x <- cbind(
            1,
            outer(
              X = times[ok],
              Y = seq_len(degree),
              FUN = "^"
            )
          )
        }

        fit <- stats::lm.fit(
          x = x,
          y = y[ok]
        )

        residualized[
          index[ok]
        ] <- fit$residuals
      }
    }

    if (replace) {
      data[[var]] <- residualized
    } else {
      data[[paste0(prefix, "_", var)]] <- residualized
    }
  }

  rownames(data) <- NULL
  data
}
