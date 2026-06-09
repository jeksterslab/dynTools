.DynToolsUseParallel <- function(ncores, n_tasks) {
  if (is.null(ncores)) {
    FALSE
  } else {
    ncores <- as.integer(ncores[1])
    !is.na(ncores) &&
      ncores > 1L &&
      n_tasks > 1L
  }
}
