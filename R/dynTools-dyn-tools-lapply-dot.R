.DynToolsLapply <- function(X,
                            FUN,
                            ncores = NULL,
                            ...) {
  n_tasks <- length(X)

  if (!.DynToolsUseParallel(ncores, n_tasks)) {
    lapply(
      X = X,
      FUN = FUN,
      ...
    )
  } else {
    ncores <- min(
      as.integer(ncores[1]),
      n_tasks
    )

    if (.Platform$OS.type == "windows") {
      cl <- parallel::makeCluster(ncores)
      on.exit(
        parallel::stopCluster(cl),
        add = TRUE
      )

      parallel::parLapply(
        cl = cl,
        X = X,
        fun = FUN,
        ...
      )
    } else {
      parallel::mclapply(
        X = X,
        FUN = FUN,
        ...,
        mc.cores = ncores,
        mc.preschedule = TRUE,
        mc.set.seed = FALSE
      )
    }
  }
}
