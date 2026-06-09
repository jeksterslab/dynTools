#' Insert NAs for Missing Observations
#'
#' The function creates a sequence of time values.
#' It starts with the smallest time value as the starting point
#' and the largest time value as the endpoint.
#' The sequence is incremented by `delta_t`.
#' This new sequence is combined with the existing empirical time values.
#' For any specific time value where there are no observations,
#' NAs are inserted.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param delta_t Positive number.
#'   Time interval.
#'
#' @return Returns a data frame.
#'
#' @examples
#' # prepare parameters
#' set.seed(42)
#' ## number of individuals
#' n <- 5
#' ## time points
#' time <- 5
#' ## dynamic structure
#' p <- 3
#' mu0 <- rep(x = 0, times = p)
#' sigma0 <- 0.001 * diag(p)
#' sigma0_l <- t(chol(sigma0))
#' alpha <- rep(x = 0, times = p)
#' beta <- 0.50 * diag(p)
#' psi <- 0.001 * diag(p)
#' psi_l <- t(chol(psi))
#'
#' library(simStateSpace)
#' ssm <- SimSSMVARFixed(
#'   n = n,
#'   time = time,
#'   mu0 = mu0,
#'   sigma0_l = sigma0_l,
#'   alpha = alpha,
#'   beta = beta,
#'   psi_l = psi_l,
#'   type = 0
#' )
#' data <- as.data.frame(ssm)
#' InsertNA(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = paste0("y", 1:p),
#'   delta_t = 0.10
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
InsertNA <- function(data,
                     id,
                     time,
                     observed,
                     covariates = NULL,
                     delta_t,
                     ncores = NULL) {
  stopifnot(delta_t > 0)

  data <- .DynToolsSelectSort(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates
  )

  if (nrow(data) == 0L) {
    data
  } else {
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

    ids <- unique(data[[id]])

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

    key_data <- paste(
      data[[id]],
      data[[time]],
      sep = "\r"
    )

    key_out <- paste(
      out[[id]],
      out[[time]],
      sep = "\r"
    )

    pos <- match(
      x = key_data,
      table = key_out
    )

    if (anyDuplicated(key_data)) {
      stop(
        "`InsertNA()` requires unique `id`-`time` combinations."
      )
    }

    out[
      pos,
      names(data)
    ] <- data

    rownames(out) <- NULL
    out
  }
}
