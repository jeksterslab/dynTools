#' Print Method for Object of Class `dynutillist`
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param x an object of class `dynutillist`.
#' @param ... further arguments.
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
#' out <- SubsetByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = paste0("y", 1:p)
#' )
#' print(out)
#'
#' @keywords methods
#' @export
print.dynutillist <- function(x,
                              ...) {
  attributes(x)$args <- NULL
  attributes(x)$idx <- NULL
  attributes(x)$class <- NULL
  base::print(x)
}
