#' Check for NAs in Initial Row By ID
#'
#' The function checks if there are missing values
#' for the initial row by ID.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams InsertNA
#'
#' @return Returns a vector of ID numbers
#'   where the initial row has any missing value.
#'
#' @examples
#' if (requireNamespace("simStateSpace", quietly = TRUE)) {
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
#' # Replace first row with NA
#' data[1, paste0("y", 1:p)] <- NA
#' InitialNA(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = paste0("y", 1:p)
#' )
#' }
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
InitialNA <- function(data,
                      id,
                      time,
                      observed,
                      covariates = NULL,
                      ncores = NULL) {
  data <- .DynToolsSelectSort(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates
  )

  if (nrow(data) == 0L) {
    data[[id]][0]
  } else {
    run <- rle(data[[id]])
    start <- cumsum(run$lengths) - run$lengths + 1L

    first_rows <- data[
      start, ,
      drop = FALSE
    ]

    first_rows[
      !stats::complete.cases(first_rows),
      id
    ]
  }
}
