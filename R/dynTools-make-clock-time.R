#' Make Clock Time
#'
#' The function combines a date and a clock time into a `POSIXct` vector.
#' Clock time can be supplied as decimal hours, for example `13.5`, or as a
#' character time, for example `"13:30"` or `"13:30:00"`.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param date Date vector.
#'   Dates can be supplied as `Date`, `POSIXt`, or character values.
#' @param time Numeric or character vector.
#'   Clock time in decimal hours, `"HH:MM"`, or `"HH:MM:SS"` format.
#' @param tz Character string.
#'   Time zone passed to `as.POSIXct()`.
#' @param date_formats Character vector.
#'   Date formats used to parse character dates.
#' @param invalid Character string.
#'   If `invalid = "NA"`, invalid clock times are returned as `NA`.
#'   If `invalid = "error"`, invalid clock times throw an error.
#'
#' @return Returns a `POSIXct` vector.
#'
#' @examples
#' MakeClockTime(
#'   date = "2020-01-02",
#'   time = 13.5,
#'   tz = "America/New_York"
#' )
#'
#' MakeClockTime(
#'   date = "01/02/20",
#'   time = "13:30",
#'   tz = "America/New_York"
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
MakeClockTime <- function(date,
                          time,
                          tz = "UTC",
                          date_formats = c(
                            "%m/%d/%y",
                            "%m/%d/%Y",
                            "%Y-%m-%d"
                          ),
                          invalid = c("NA", "error")) {
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

  if (
    !is.character(date_formats) ||
      length(date_formats) == 0L ||
      any(is.na(date_formats)) ||
      any(date_formats == "")
  ) {
    stop(
      "`date_formats` must be a non-empty character vector.",
      call. = FALSE
    )
  }

  invalid <- match.arg(invalid)

  n_date <- length(date)
  n_time <- length(time)

  if (n_date == 0L || n_time == 0L) {
    return(
      as.POSIXct(
        numeric(0),
        origin = "1970-01-01",
        tz = tz
      )
    )
  }

  n <- max(n_date, n_time)

  if (n_date != n && n_date != 1L) {
    stop(
      "`date` and `time` must have the same length, unless one has length 1.",
      call. = FALSE
    )
  }

  if (n_time != n && n_time != 1L) {
    stop(
      "`date` and `time` must have the same length, unless one has length 1.",
      call. = FALSE
    )
  }

  if (n_date == 1L && n > 1L) {
    date <- rep(
      x = date,
      times = n
    )
  }

  if (n_time == 1L && n > 1L) {
    time <- rep(
      x = time,
      times = n
    )
  }

  if (inherits(date, "Date")) {
    date_parsed <- as.Date(date)
  } else if (inherits(date, "POSIXt")) {
    date_parsed <- as.Date(
      x = date,
      tz = tz
    )
  } else {
    date_chr <- trimws(
      as.character(date)
    )
    date_chr[
      date_chr == ""
    ] <- NA_character_

    date_parsed <- as.Date(
      rep(
        x = NA_character_,
        times = n
      )
    )

    remaining <- !is.na(date_chr)

    for (fmt in date_formats) {
      if (!any(remaining)) {
        break
      }

      parsed <- suppressWarnings(
        as.Date(
          x = date_chr[remaining],
          format = fmt
        )
      )

      ok <- !is.na(parsed)

      if (any(ok)) {
        remaining_index <- which(remaining)
        date_parsed[
          remaining_index[ok]
        ] <- parsed[ok]

        remaining[
          remaining_index[ok]
        ] <- FALSE
      }
    }
  }

  time_num <- rep(
    x = NA_real_,
    times = n
  )

  invalid_time <- rep(
    x = FALSE,
    times = n
  )

  if (is.numeric(time)) {
    time_num <- as.numeric(time)
    invalid_time <- !is.na(time_num) & (
      !is.finite(time_num) |
        time_num < 0 |
        time_num > 24
    )
  } else {
    time_chr <- trimws(
      as.character(time)
    )
    time_chr[
      time_chr == ""
    ] <- NA_character_

    has_colon <- !is.na(time_chr) & grepl(
      pattern = ":",
      x = time_chr,
      fixed = TRUE
    )

    if (any(has_colon)) {
      pos <- which(has_colon)

      parsed_colon <- lapply(
        X = strsplit(
          x = time_chr[pos],
          split = ":",
          fixed = TRUE
        ),
        FUN = function(x) {
          if (!(length(x) %in% c(2L, 3L))) {
            return(
              c(
                value = NA_real_,
                invalid = 1
              )
            )
          }

          x <- suppressWarnings(
            as.numeric(x)
          )

          if (any(is.na(x)) || any(!is.finite(x))) {
            return(
              c(
                value = NA_real_,
                invalid = 1
              )
            )
          }

          hour <- x[1L]
          minute <- x[2L]
          second <- if (length(x) == 3L) {
            x[3L]
          } else {
            0
          }

          bad <- hour < 0 ||
            hour > 24 ||
            minute < 0 ||
            minute >= 60 ||
            second < 0 ||
            second >= 60 ||
            (hour == 24 && (minute > 0 || second > 0))

          if (bad) {
            c(
              value = NA_real_,
              invalid = 1
            )
          } else {
            c(
              value = hour + minute / 60 + second / 3600,
              invalid = 0
            )
          }
        }
      )

      parsed_colon <- do.call(
        what = "rbind",
        args = parsed_colon
      )

      time_num[pos] <- parsed_colon[
        ,
        "value"
      ]

      invalid_time[pos] <- parsed_colon[
        ,
        "invalid"
      ] == 1
    }

    if (any(!has_colon & !is.na(time_chr))) {
      pos <- which(!has_colon & !is.na(time_chr))

      parsed_num <- suppressWarnings(
        as.numeric(time_chr[pos])
      )

      time_num[pos] <- parsed_num

      invalid_time[pos] <- is.na(parsed_num) |
        !is.finite(parsed_num) |
        parsed_num < 0 |
        parsed_num > 24
    }
  }

  if (any(invalid_time)) {
    if (invalid == "error") {
      stop(
        "`time` contains invalid clock time values.",
        call. = FALSE
      )
    }

    time_num[invalid_time] <- NA_real_
  }

  out <- as.POSIXct(
    x = rep(
      x = NA_real_,
      times = n
    ),
    origin = "1970-01-01",
    tz = tz
  )

  ok <- !is.na(date_parsed) & !is.na(time_num)

  if (any(ok)) {
    seconds <- round(
      time_num[ok] * 3600
    )

    base <- as.POSIXct(
      x = as.character(date_parsed[ok]),
      tz = tz,
      format = "%Y-%m-%d"
    )

    out[ok] <- base + seconds
  }

  out
}
