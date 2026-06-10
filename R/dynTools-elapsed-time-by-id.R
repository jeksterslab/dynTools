#' Create Elapsed Time by ID
#'
#' The function creates an elapsed-time variable within ID. For date-time
#' variables, elapsed time is computed with `difftime()`. For numeric time
#' variables, elapsed time is computed by subtraction, optionally converting
#' from `input_units` to `units`.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param output Character string.
#'   Name of the elapsed-time variable.
#' @param units Character string.
#'   Units for the output elapsed time.
#' @param origin Character string.
#'   If `origin = "by_id"`, each ID's origin is its own minimum non-missing
#'   time. If `origin = "global"`, all IDs use the global minimum non-missing
#'   time.
#' @param input_units Character string or `NULL`.
#'   Units of numeric input time. If `NULL`, numeric time is assumed to already
#'   be in the desired output scale and only subtraction is performed.
#' @param replace Logical.
#'   If `TRUE`, replace the original `time` variable. If `FALSE`, append
#'   `output`.
#'
#' @return Returns a data frame.
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 2, 2),
#'   datetime = as.POSIXct(
#'     c(
#'       "2020-01-01 00:00:00",
#'       "2020-01-02 00:00:00",
#'       "2020-01-03 12:00:00",
#'       "2020-01-04 00:00:00"
#'     ),
#'     tz = "UTC"
#'   )
#' )
#' data
#'
#' ElapsedTimeByID(
#'   data = data,
#'   id = "id",
#'   time = "datetime",
#'   output = "time",
#'   units = "days"
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
ElapsedTimeByID <- function(data,
                            id,
                            time,
                            output = "time_elapsed",
                            units = "days",
                            origin = c(
                              "by_id",
                              "global"
                            ),
                            input_units = NULL,
                            replace = FALSE) {
  if (!is.data.frame(data)) {
    stop(
      "`data` must be a data frame.",
      call. = FALSE
    )
  }

  if (anyDuplicated(names(data))) {
    stop(
      "`data` must have unique column names.",
      call. = FALSE
    )
  }

  if (
    !is.character(id) ||
      length(id) != 1L ||
      is.na(id) ||
      id == ""
  ) {
    stop(
      "`id` must be a non-empty character string.",
      call. = FALSE
    )
  }

  if (
    !is.character(time) ||
      length(time) != 1L ||
      is.na(time) ||
      time == ""
  ) {
    stop(
      "`time` must be a non-empty character string.",
      call. = FALSE
    )
  }

  if (
    !is.character(output) ||
      length(output) != 1L ||
      is.na(output) ||
      output == ""
  ) {
    stop(
      "`output` must be a non-empty character string.",
      call. = FALSE
    )
  }

  if (
    !is.logical(replace) ||
      length(replace) != 1L ||
      is.na(replace)
  ) {
    stop(
      "`replace` must be `TRUE` or `FALSE`.",
      call. = FALSE
    )
  }

  origin <- match.arg(origin)

  allowed_units <- c(
    "secs",
    "mins",
    "hours",
    "days",
    "weeks"
  )

  if (
    !is.character(units) ||
      length(units) != 1L ||
      is.na(units) ||
      !(units %in% allowed_units)
  ) {
    stop(
      paste(
        "`units`",
        "must be one of",
        "\"secs\", \"mins\", \"hours\", \"days\", or \"weeks\"."
      ),
      call. = FALSE
    )
  }

  if (!is.null(input_units)) {
    if (
      !is.character(input_units) ||
        length(input_units) != 1L ||
        is.na(input_units) ||
        !(input_units %in% allowed_units)
    ) {
      stop(
        paste(
          "`input_units`",
          "must be `NULL` or one of",
          "\"secs\", \"mins\", \"hours\", \"days\", or \"weeks\"."
        ),
        call. = FALSE
      )
    }
  }

  missing_vars <- setdiff(
    x = c(
      id,
      time
    ),
    y = names(data)
  )

  if (length(missing_vars) > 0L) {
    stop(
      paste0(
        "The following variables are not in `data`: ",
        paste(missing_vars, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  if (!replace && output %in% names(data)) {
    stop(
      paste0(
        "`output` already exists in `data`: ",
        output,
        "."
      ),
      call. = FALSE
    )
  }

  if (any(is.na(data[[id]]))) {
    stop(
      "`id` must not contain missing values.",
      call. = FALSE
    )
  }

  if (nrow(data) == 0L) {
    if (replace) {
      data[[time]] <- numeric(0)
    } else {
      data[[output]] <- numeric(0)
    }

    rownames(data) <- NULL
    return(data)
  }

  data <- data[
    order(
      data[[id]],
      data[[time]],
      na.last = TRUE
    ), ,
    drop = FALSE
  ]

  x <- data[[time]]

  elapsed <- rep(
    x = NA_real_,
    times = nrow(data)
  )

  seconds <- c(
    secs = 1,
    mins = 60,
    hours = 3600,
    days = 86400,
    weeks = 604800
  )

  is_datetime <- inherits(
    x = x,
    what = "POSIXt"
  ) || inherits(
    x = x,
    what = "Date"
  )

  is_numeric_time <- is.numeric(x)

  if (!is_datetime && !is_numeric_time) {
    stop(
      "`time` must be numeric, Date, or POSIXt.",
      call. = FALSE
    )
  }

  if (origin == "global") {
    ok_global <- !is.na(x)

    if (any(ok_global)) {
      origin_value_global <- min(
        x[ok_global],
        na.rm = TRUE
      )
    } else {
      origin_value_global <- NA
    }
  }

  run <- rle(data[[id]])
  end <- cumsum(run$lengths)
  start <- end - run$lengths + 1L

  for (j in seq_along(start)) {
    index <- seq.int(
      from = start[j],
      to = end[j]
    )

    xj <- x[index]
    ok <- !is.na(xj)

    if (!any(ok)) {
      next
    }

    if (origin == "by_id") {
      origin_value <- min(
        xj[ok],
        na.rm = TRUE
      )
    } else {
      origin_value <- origin_value_global
    }

    if (is.na(origin_value)) {
      next
    }

    if (is_datetime) {
      elapsed[index[ok]] <- as.numeric(
        difftime(
          time1 = xj[ok],
          time2 = origin_value,
          units = units
        )
      )
    } else {
      raw_elapsed <- xj[ok] - origin_value

      if (is.null(input_units)) {
        elapsed[index[ok]] <- raw_elapsed
      } else {
        elapsed[index[ok]] <- raw_elapsed *
          seconds[input_units] /
          seconds[units]
      }
    }
  }

  if (replace) {
    data[[time]] <- elapsed
  } else {
    data[[output]] <- elapsed
  }

  rownames(data) <- NULL
  data
}
