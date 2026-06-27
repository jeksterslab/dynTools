#' Get Observed Initial Means and Covariances
#'
#' The function extracts the first observed time point for each ID and computes
#' the sample mean vector and sample covariance matrix of the observed variables
#' across IDs. The resulting mean vector and covariance matrix can be used as
#' fixed initial conditions in dynamic models.
#'
#' Rows are sorted by ID and time before selecting the first row for each ID.
#' Missing observed values are ignored when computing the mean vector. The
#' covariance matrix is computed using complete cases of the selected first-time
#' observations.
#'
#' If the covariance matrix is not positive definite, a small ridge value is
#' added to the diagonal.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param ridge Positive numeric.
#'   Small value added to the diagonal of the covariance matrix if the estimated
#'   covariance matrix is not positive definite.
#'
#' @return Returns a list with the following elements:
#' \describe{
#'   \item{\code{data}}{Data frame containing the first observed time point for
#'   each ID and the selected observed variables.}
#'   \item{\code{mean}}{Numeric vector of observed-variable means computed from
#'   the first observed time point across IDs.}
#'   \item{\code{cov}}{Observed-variable covariance matrix computed from
#'   complete cases of the first observed time point across IDs.}
#'   \item{\code{n}}{Number of IDs with a first observed row.}
#'   \item{\code{n_complete}}{Number of IDs with complete data on all selected
#'   observed variables at the first observed time point.}
#' }
#'
#' @examples
#' data <- data.frame(
#'   id = rep(1:3, each = 4),
#'   time = rep(1:4, times = 3),
#'   y1 = c(1, 2, 3, 4, 2, 3, 4, 5, 3, 4, 5, 6),
#'   y2 = c(4, 3, 2, 1, 5, 4, 3, 2, 6, 5, 4, 3)
#' )
#' data
#'
#' init <- GetObservedInitial(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = c("y1", "y2")
#' )
#'
#' init$data
#' init$mean
#' init$cov
#' init$n
#' init$n_complete
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
GetObservedInitial <- function(data,
                               id,
                               time,
                               observed,
                               ridge = 1e-6) {
  ## sort by ID and time
  data_ord <- data[order(data[[id]], data[[time]]), ]

  ## first observed time point per ID
  first_idx <- !duplicated(data_ord[[id]])

  init_data <- data_ord[first_idx, observed, drop = FALSE]
  rownames(init_data) <- NULL

  init_mean <- colMeans(
    init_data,
    na.rm = TRUE
  )

  init_cov <- stats::cov(
    init_data,
    use = "complete.obs"
  )

  ## optional ridge if covariance is not positive definite
  eig <- eigen(init_cov, symmetric = TRUE, only.values = TRUE)$values

  if (any(eig <= 0)) {
    init_cov <- init_cov + diag(ridge, nrow(init_cov))
  }

  list(
    data = init_data,
    mean = init_mean,
    cov = init_cov,
    n = nrow(init_data),
    n_complete = sum(stats::complete.cases(init_data))
  )
}
