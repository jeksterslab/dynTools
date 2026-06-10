## ---- test-dynTools-plot-by-id
lapply(
  X = 1,
  FUN = function(i,
                 text) {
    message(text)

    if (requireNamespace("simStateSpace", quietly = TRUE)) {
      set.seed(42)

      n <- 5
      time <- 5
      p <- 3

      mu0 <- rep(x = 0, times = p)
      sigma0 <- 0.001 * diag(p)
      sigma0_l <- t(chol(sigma0))
      alpha <- rep(x = 0, times = p)
      beta <- 0.50 * diag(p)
      psi <- 0.001 * diag(p)
      psi_l <- t(chol(psi))

      ssm <- simStateSpace::SimSSMVARFixed(
        n = n,
        time = time,
        mu0 = mu0,
        sigma0_l = sigma0_l,
        alpha = alpha,
        beta = beta,
        psi_l = psi_l,
        type = 0
      )

      data <- as.data.frame(ssm)

      PlotByID(
        data = data,
        id = "id",
        time = "time",
        observed = paste0("y", 1:p),
        legend = TRUE
      )

      PlotByID(
        data = data,
        id = "id",
        time = "time",
        observed = paste0("y", 1:p),
        ids = 1:3,
        times = c(0, 3),
        legend = TRUE
      )
    }
  },
  text = "test-dynTools-plot-by-id"
)
