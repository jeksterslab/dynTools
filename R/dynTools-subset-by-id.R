#' Subset Data Set by ID
#'
#' The function creates a list of data frames for each ID.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Returns a list by ID numbers.
#'
#' @param data Data frame.
#'   A data frame object of data for potentially
#'   multiple subjects that contain
#'   a column of subject ID numbers
#'   (i.e., an ID variable),
#'   a column indicating subject-specific measurement occasions
#'   (i.e., a TIME variable),
#'   at least one column of observed values.
#' @param observed Character vector.
#'   A vector of character strings
#'   of the names of the observed variables in the data.
#' @param covariates Character vector.
#'   A vector of character strings
#'   of the names of the covariates in the data.
#' @param id Character string.
#'   A character string of the name of the ID variable in the data.
#' @param time Character string.
#'   A character string of the name of the TIME variable in the data.
#' @param ncores Positive integer.
#'   Number of cores to use.
#'   If `ncores = NULL`,
#'   use a single core.
#'   Consider using multiple cores
#'   when number of individuals is large.
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
#' SubsetByID(
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
SubsetByID <- function(data,
                       id,
                       time,
                       observed,
                       covariates = NULL,
                       ncores = NULL) {
  stopifnot(
    is.data.frame(data)
  )

  data <- .DynToolsSelectSort(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates
  )

  ids <- unique(data[[id]])

  if (nrow(data) == 0L) {
    output <- list()
  } else {
    run <- rle(data[[id]])
    end <- cumsum(run$lengths)
    start <- end - run$lengths + 1L

    output <- vector(
      mode = "list",
      length = length(start)
    )

    for (j in seq_along(start)) {
      output[[j]] <- data[
        seq.int(
          from = start[j],
          to = end[j]
        ), ,
        drop = FALSE
      ]
      rownames(output[[j]]) <- NULL
    }

    names(output) <- as.character(ids)
  }

  attributes(output)$args <- list(
    id = id,
    time = time,
    observed = observed,
    covariates = covariates
  )

  attributes(output)$idx <- list(
    id = ids,
    time = unique(data[[time]])
  )

  class(output) <- c(
    "dynutillist",
    class(output)
  )

  output
}
