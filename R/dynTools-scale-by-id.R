#' Scale by ID
#'
#' The function scales the data by ID.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param scale Logical.
#'   If `scale = TRUE`, standardize by `id`.
#'   If `scale = FALSE`, mean center by `id`.
#' @param obs_skip Character vector.
#'   A vector of character strings
#'   of the names of the observed variables to skip centering/scaling.
#' @param cov_skip Character vector.
#'   A vector of character strings
#'   of the names of the covariates to skip centering/scaling.
#'
#' @return Returns a data frame.
#'
#' @examples
#' if (requireNamespace("simStateSpace", quietly = TRUE)) {
#'   # prepare parameters
#'   set.seed(42)
#'   ## number of individuals
#'   n <- 5
#'   ## time points
#'   time <- 5
#'   ## dynamic structure
#'   p <- 3
#'   mu0 <- rep(x = 0, times = p)
#'   sigma0 <- 0.001 * diag(p)
#'   sigma0_l <- t(chol(sigma0))
#'   alpha <- rep(x = 0, times = p)
#'   beta <- 0.50 * diag(p)
#'   psi <- 0.001 * diag(p)
#'   psi_l <- t(chol(psi))
#'
#'   library(simStateSpace)
#'   ssm <- SimSSMVARFixed(
#'     n = n,
#'     time = time,
#'     mu0 = mu0,
#'     sigma0_l = sigma0_l,
#'     alpha = alpha,
#'     beta = beta,
#'     psi_l = psi_l,
#'     type = 0
#'   )
#'   data <- as.data.frame(ssm)
#'   ScaleByID(
#'     data = data,
#'     id = "id",
#'     time = "time",
#'     observed = paste0("y", 1:p)
#'   )
#' }
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
ScaleByID <- function(data,
                      id,
                      time,
                      observed,
                      covariates = NULL,
                      scale = TRUE,
                      obs_skip = NULL,
                      cov_skip = NULL,
                      ncores = NULL) {
  data <- .DynToolsSelectSort(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates
  )

  if (is.null(obs_skip)) {
    obs <- observed
  } else {
    obs <- observed[
      !observed %in% obs_skip
    ]
  }

  obs <- obs[
    obs %in% names(data)
  ]

  if (is.null(covariates)) {
    covs <- NULL
  } else if (is.null(cov_skip)) {
    covs <- covariates
  } else {
    covs <- covariates[
      !covariates %in% cov_skip
    ]
  }

  covs <- covs[
    covs %in% names(data)
  ]

  varnames <- c(
    obs,
    covs
  )

  if (length(varnames) > 0L && nrow(data) > 0L) {
    x <- as.matrix(
      data[
        ,
        varnames,
        drop = FALSE
      ]
    )

    storage.mode(x) <- "double"

    group <- match(
      x = data[[id]],
      table = unique(data[[id]])
    )

    ok <- !is.na(x)

    count <- rowsum(
      x = ok + 0,
      group = group,
      reorder = FALSE
    )

    x0 <- x
    x0[!ok] <- 0

    sum_x <- rowsum(
      x = x0,
      group = group,
      reorder = FALSE
    )

    mean_x <- sum_x / count

    centered <- x - mean_x[
      group, ,
      drop = FALSE
    ]

    if (scale) {
      centered0 <- centered
      centered0[!ok] <- 0

      ss <- rowsum(
        x = centered0^2,
        group = group,
        reorder = FALSE
      )

      sd_x <- sqrt(
        ss / (count - 1)
      )

      sd_x[
        !is.na(sd_x) & sd_x == 0
      ] <- 1

      centered <- centered / sd_x[
        group, ,
        drop = FALSE
      ]
    }

    data[
      ,
      varnames
    ] <- centered
  }

  rownames(data) <- NULL
  data
}
