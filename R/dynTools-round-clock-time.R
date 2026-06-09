#' Round Clock Time
#'
#' The function rounds, floors, or ceilings clock times to a specified unit.
#' It supports `POSIXt`, `Date`, and numeric time values.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param x A `POSIXt`, `Date`, or numeric vector.
#' @param unit Character string.
#'   Unit to round to. Supported values are `"second"`, `"minute"`, `"hour"`,
#'   `"day"`, and their plural forms.
#' @param method Character string.
#'   One of `"round"`, `"floor"`, or `"ceiling"`.
#' @param origin Origin for numeric time values.
#'   Only used if `x` is numeric.
#' @param tz Character string.
#'   Time zone used when numeric time values are converted to `POSIXct`.
#'
#' @return Returns a vector with rounded times.
#'
#' @examples
#' x <- as.POSIXct(
#'   "2020-01-01 10:31:00",
#'   tz = "America/New_York"
#' )
#'
#' RoundClockTime(
#'   x = x,
#'   unit = "hour"
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
RoundClockTime <- function(x,
                           unit = "hour",
                           method = c(
                             "round",
                             "floor",
                             "ceiling"
                           ),
                           origin = "1970-01-01",
                           tz = "UTC") {
  method <- match.arg(method)

  if (
    !is.character(unit) ||
      length(unit) != 1L ||
      is.na(unit) ||
      unit == ""
  ) {
    stop(
      "`unit` must be a non-empty character string.",
      call. = FALSE
    )
  }

  if (
    !is.character(tz) ||
      length(tz) != 1L ||
      is.na(tz) ||
      tz == ""
  ) {
    stop(
      "`tz` must be a non-empty character string.",
      call. = FALSE
    )
  }

  unit <- match.arg(
    arg = unit,
    choices = c(
      "second",
      "seconds",
      "minute",
      "minutes",
      "hour",
      "hours",
      "day",
      "days"
    )
  )

  unit <- switch(unit,
    second = "secs",
    seconds = "secs",
    minute = "mins",
    minutes = "mins",
    hour = "hours",
    hours = "hours",
    day = "days",
    days = "days"
  )

  if (inherits(x, "POSIXt")) {
    if (method == "round") {
      out <- round(
        x = x,
        units = unit
      )
    } else if (method == "floor") {
      out <- trunc(
        x = x,
        units = unit
      )
    } else {
      out <- round(
        x = x,
        units = unit
      )

      floored <- trunc(
        x = x,
        units = unit
      )

      out <- floored

      needs_ceiling <- !is.na(x) & x != floored

      if (any(needs_ceiling)) {
        increment <- switch(unit,
          secs = 1,
          mins = 60,
          hours = 3600,
          days = 86400
        )

        out[needs_ceiling] <- floored[needs_ceiling] + increment
      }
    }

    return(out)
  }

  if (inherits(x, "Date")) {
    if (unit != "days") {
      stop(
        "`Date` values can only be rounded to `unit = \"day\"`.",
        call. = FALSE
      )
    }

    return(x)
  }

  if (is.numeric(x)) {
    step <- switch(unit,
      secs = 1,
      mins = 60,
      hours = 3600,
      days = 86400
    )

    out <- switch(method,
      round = round(x / step) * step,
      floor = floor(x / step) * step,
      ceiling = ceiling(x / step) * step
    )

    return(
      as.POSIXct(
        x = out,
        origin = origin,
        tz = tz
      )
    )
  }

  stop(
    "`x` must be POSIXt, Date, or numeric.",
    call. = FALSE
  )
}
