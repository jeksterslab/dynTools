.DynToolsTimeGap <- function(x,
                             time_scale = 1,
                             posix_unit = "hours") {
  if (length(x) <= 1L) {
    return(numeric(0))
  }

  x <- sort(x)

  gap <- diff(x)

  if (inherits(x, "POSIXt") || inherits(x, "Date")) {
    unit <- posix_unit
    if (unit == "auto") {
      unit <- if (inherits(x, "Date")) "days" else "hours"
    }
    as.numeric(gap, units = unit)
  } else {
    as.numeric(gap) * time_scale
  }
}
