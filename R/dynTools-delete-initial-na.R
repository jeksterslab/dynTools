#' Delete for NAs in Initial Row By ID
#'
#' The function removes initial rows by ID if they contain missing values.
#' This process is repeated until the first row per ID no longer has missing
#' observations.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#'
#' @return Returns a data frame.
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
#' DeleteInitialNA(
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
DeleteInitialNA <- function(data,
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

  if (nrow(data) > 0L) {
    ok <- stats::complete.cases(data)

    if (!all(ok)) {
      run <- rle(data[[id]])
      end <- cumsum(run$lengths)
      start <- end - run$lengths + 1L

      keep <- .DynToolsLapply(
        X = seq_along(start),
        FUN = .DeleteInitialNAKeepIndex,
        ncores = ncores,
        start = start,
        end = end,
        ok = ok
      )

      keep <- unlist(
        x = keep,
        use.names = FALSE
      )

      data <- data[
        keep, ,
        drop = FALSE
      ]
    }
  }

  rownames(data) <- NULL
  data
}
