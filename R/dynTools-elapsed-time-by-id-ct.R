#' Create CT-Scaled Elapsed Time by ID
#'
#' The function creates an elapsed-time variable within ID and rescales it for
#' continuous-time state space modeling. The rescaling divides elapsed time by
#' a typical positive consecutive time interval so that the typical `delta_t`
#' is approximately 1.
#'
#' This is useful for continuous-time models because the units of time are
#' arbitrary, but poorly scaled time can lead to drift parameters that are very
#' large or very small.
#'
#' The minimum positive consecutive interval is reported as a diagnostic but is
#' not used as a scaling option. The goal is to make the typical consecutive
#' interval approximately 1, not the smallest interval.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams ElapsedTimeByID
#' @param scale Character string.
#'   Method used to compute the time-scaling divisor.
#'   If `scale = "mean_dt"`, the divisor is the mean positive consecutive
#'   elapsed-time interval.
#'   If `scale = "median_dt"`, the divisor is the median positive consecutive
#'   elapsed-time interval.
#' @param scale_value Numeric or `NULL`.
#'   Optional user-supplied positive scaling divisor in the elapsed-time
#'   `units`. If supplied, this value is used instead of estimating the divisor
#'   from the data.
#'
#' @return Returns a data frame. The returned data frame has an attribute
#'   named `"time_ct_scale"` containing the scaling information.
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 2, 2),
#'   datetime = as.POSIXct(
#'     c(
#'       "2020-01-01 00:00:00",
#'       "2020-01-01 06:00:00",
#'       "2020-01-03 12:00:00",
#'       "2020-01-04 00:00:00"
#'     ),
#'     tz = "UTC"
#'   )
#' )
#'
#' data_ct <- ElapsedTimeByIDCT(
#'   data = data,
#'   id = "id",
#'   time = "datetime",
#'   output = "time_ct",
#'   units = "hours",
#'   scale = "mean_dt"
#' )
#'
#' attr(data_ct, "time_ct_scale")
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
ElapsedTimeByIDCT <- function(data,
                              id,
                              time,
                              output = "time_ct",
                              units = "hours",
                              origin = c(
                                "by_id",
                                "global"
                              ),
                              input_units = NULL,
                              scale = c(
                                "mean_dt",
                                "median_dt"
                              ),
                              scale_value = NULL,
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

  scale <- match.arg(scale)

  if (!is.null(scale_value)) {
    if (
      !is.numeric(scale_value) ||
        length(scale_value) != 1L ||
        is.na(scale_value) ||
        !is.finite(scale_value) ||
        scale_value <= 0
    ) {
      stop(
        "`scale_value` must be `NULL` or a positive finite numeric scalar.",
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

  temp_output <- ".elapsed_time_by_id_ct"

  while (temp_output %in% names(data)) {
    temp_output <- paste0(
      temp_output,
      "."
    )
  }

  data <- ElapsedTimeByID(
    data = data,
    id = id,
    time = time,
    output = temp_output,
    units = units,
    origin = origin,
    input_units = input_units,
    replace = FALSE
  )

  elapsed <- data[[temp_output]]

  if (nrow(data) == 0L) {
    if (replace) {
      data[[time]] <- numeric(0)
      time_variable <- time
    } else {
      data[[output]] <- numeric(0)
      time_variable <- output
    }

    data[[temp_output]] <- NULL

    attr(data, "time_ct_scale") <- list(
      variable = time_variable,
      original_units = units,
      scale = scale,
      scale_value = scale_value,
      mean_dt_original_units = NA_real_,
      median_dt_original_units = NA_real_,
      min_dt_original_units = NA_real_,
      max_dt_original_units = NA_real_,
      n_dt = 0L,
      n_positive_dt = 0L,
      interpretation = NA_character_
    )

    rownames(data) <- NULL
    return(data)
  }

  run <- rle(data[[id]])
  end <- cumsum(run$lengths)
  start <- end - run$lengths + 1L

  dt <- numeric(0)

  for (j in seq_along(start)) {
    index <- seq.int(
      from = start[j],
      to = end[j]
    )

    elapsed_j <- elapsed[index]
    elapsed_j <- elapsed_j[!is.na(elapsed_j)]

    if (length(elapsed_j) < 2L) {
      next
    }

    dt <- c(
      dt,
      diff(elapsed_j)
    )
  }

  dt <- dt[
    is.finite(dt)
  ]

  dt_positive <- dt[
    dt > 0
  ]

  if (length(dt_positive) == 0L) {
    stop(
      "No positive consecutive time intervals were found.",
      call. = FALSE
    )
  }

  if (length(dt_positive) < length(dt)) {
    warning(
      paste(
        "Non-positive consecutive time intervals",
        "were ignored when computing the CT time scale."
      ),
      call. = FALSE
    )
  }

  if (is.null(scale_value)) {
    scale_value <- switch(scale,
      mean_dt = mean(dt_positive),
      median_dt = stats::median(dt_positive)
    )
  }

  time_ct <- elapsed / scale_value

  if (replace) {
    data[[time]] <- time_ct
    time_variable <- time
  } else {
    data[[output]] <- time_ct
    time_variable <- output
  }

  data[[temp_output]] <- NULL

  attr(data, "time_ct_scale") <- list(
    variable = time_variable,
    original_units = units,
    scale = scale,
    scale_value = scale_value,
    mean_dt_original_units = mean(dt_positive),
    median_dt_original_units = median(dt_positive),
    min_dt_original_units = min(dt_positive),
    max_dt_original_units = max(dt_positive),
    n_dt = length(dt),
    n_positive_dt = length(dt_positive),
    interpretation = paste0(
      "1 CT time unit = ",
      signif(scale_value, 6),
      " ",
      units,
      "."
    )
  )

  rownames(data) <- NULL
  data
}
