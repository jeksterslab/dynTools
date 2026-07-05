#' Create CT-Scaled Elapsed Time by ID
#'
#' The function creates an elapsed-time variable within ID and rescales it for
#' continuous-time state-space modeling. The rescaling divides elapsed time by
#' a typical positive consecutive time interval so that the typical `delta_t`
#' is approximately 1.
#'
#' This scaling can improve numerical optimization because the drift and
#' diffusion parameters are estimated with respect to a better-scaled time
#' variable. However, the resulting model parameters are interpreted per
#' CT-scaled time unit, not per original time unit.
#'
#' If the original elapsed time is measured in the requested `units` and the
#' scaling divisor is \eqn{c}, then
#'
#' \deqn{
#'   t_{\mathrm{ct}} = t_{\mathrm{original}} / c.
#' }
#'
#' Consequently, drift and diffusion covariance parameters estimated using
#' \eqn{t_{\mathrm{ct}}} are on the CT-scaled time scale:
#'
#' \deqn{
#'   \Phi_{\mathrm{ct}} = c \Phi_{\mathrm{original}},
#' }
#'
#' and, for a diffusion covariance or intensity matrix,
#'
#' \deqn{
#'   \Sigma_{\mathrm{ct}} = c \Sigma_{\mathrm{original}}.
#' }
#'
#' To express estimates back in the original time units, divide drift and
#' diffusion covariance/intensity estimates by the stored `scale_value`.
#' If the diffusion parameter is a standard deviation or Cholesky factor rather
#' than a covariance/intensity matrix, divide by `sqrt(scale_value)`.
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
#'   named `"time_ct_scale"` containing the scaling information, time-scale
#'   interpretation, and conversion multipliers for drift and diffusion
#'   parameters.
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

  origin <- match.arg(origin)
  scale <- match.arg(scale)

  scale_value_supplied <- !is.null(scale_value)

  if (scale_value_supplied) {
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

  while (
    temp_output %in% names(data) ||
      temp_output == output
  ) {
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

  scale_method <- if (scale_value_supplied) {
    "scale_value"
  } else {
    scale
  }

  if (nrow(data) == 0L) {
    if (replace) {
      data[[time]] <- numeric(0)
      time_variable <- time
    } else {
      data[[output]] <- numeric(0)
      time_variable <- output
    }

    data[[temp_output]] <- NULL

    scale_value_attr <- if (scale_value_supplied) {
      scale_value
    } else {
      NA_real_
    }

    attr(data, "time_ct_scale") <- list(
      variable = time_variable,
      original_units = units,
      origin = origin,
      scale = scale_method,
      requested_scale = scale,
      scale_value = scale_value_attr,
      scale_value_supplied = scale_value_supplied,
      mean_dt_original_units = NA_real_,
      median_dt_original_units = NA_real_,
      min_dt_original_units = NA_real_,
      max_dt_original_units = NA_real_,
      n_dt = 0L,
      n_positive_dt = 0L,
      n_nonpositive_dt = 0L,
      interpretation = NA_character_,
      time_conversion = NA_character_,
      original_time_conversion = NA_character_,
      drift_ct_to_original_multiplier = NA_real_,
      drift_original_to_ct_multiplier = NA_real_,
      diffusion_covariance_ct_to_original_multiplier = NA_real_,
      diffusion_covariance_original_to_ct_multiplier = NA_real_,
      diffusion_sd_ct_to_original_multiplier = NA_real_,
      diffusion_sd_original_to_ct_multiplier = NA_real_,
      drift_conversion = NA_character_,
      diffusion_covariance_conversion = NA_character_,
      diffusion_sd_conversion = NA_character_
    )

    rownames(data) <- NULL
    return(data)
  }

  index_by_id <- split(
    x = seq_len(nrow(data)),
    f = data[[id]]
  )

  dt <- numeric(0)

  for (j in seq_along(index_by_id)) {
    index <- index_by_id[[j]]

    elapsed_j <- elapsed[index]
    elapsed_j <- elapsed_j[
      !is.na(elapsed_j) &
        is.finite(elapsed_j)
    ]

    if (length(elapsed_j) < 2L) {
      next
    }

    elapsed_j <- sort(elapsed_j)

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

  if (!scale_value_supplied) {
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

  drift_ct_to_original_multiplier <- 1 / scale_value
  drift_original_to_ct_multiplier <- scale_value

  diffusion_covariance_ct_to_original_multiplier <- 1 / scale_value
  diffusion_covariance_original_to_ct_multiplier <- scale_value

  diffusion_sd_ct_to_original_multiplier <- 1 / sqrt(scale_value)
  diffusion_sd_original_to_ct_multiplier <- sqrt(scale_value)

  attr(data, "time_ct_scale") <- list(
    variable = time_variable,
    original_units = units,
    origin = origin,
    scale = scale_method,
    requested_scale = scale,
    scale_value = scale_value,
    scale_value_supplied = scale_value_supplied,
    mean_dt_original_units = mean(dt_positive),
    median_dt_original_units = stats::median(dt_positive),
    min_dt_original_units = min(dt_positive),
    max_dt_original_units = max(dt_positive),
    n_dt = length(dt),
    n_positive_dt = length(dt_positive),
    n_nonpositive_dt = length(dt) - length(dt_positive),
    interpretation = paste0(
      "1 CT time unit = ",
      signif(scale_value, 6),
      " ",
      units,
      "."
    ),
    time_conversion = paste0(
      time_variable,
      " = elapsed time in ",
      units,
      " / ",
      signif(scale_value, 6),
      "."
    ),
    original_time_conversion = paste0(
      "Elapsed time in ",
      units,
      " = ",
      time_variable,
      " * ",
      signif(scale_value, 6),
      "."
    ),
    drift_ct_to_original_multiplier = drift_ct_to_original_multiplier,
    drift_original_to_ct_multiplier = drift_original_to_ct_multiplier,
    diffusion_covariance_ct_to_original_multiplier =
      diffusion_covariance_ct_to_original_multiplier,
    diffusion_covariance_original_to_ct_multiplier =
      diffusion_covariance_original_to_ct_multiplier,
    diffusion_sd_ct_to_original_multiplier =
      diffusion_sd_ct_to_original_multiplier,
    diffusion_sd_original_to_ct_multiplier =
      diffusion_sd_original_to_ct_multiplier,
    drift_conversion = paste0(
      "To convert drift estimates from CT-scaled units back to per ",
      units,
      ", multiply by ",
      signif(drift_ct_to_original_multiplier, 6),
      ". Equivalently, divide by ",
      signif(scale_value, 6),
      "."
    ),
    diffusion_covariance_conversion = paste0(
      "To convert diffusion covariance/intensity estimates from CT-scaled ",
      "units back to per ",
      units,
      ", multiply by ",
      signif(diffusion_covariance_ct_to_original_multiplier, 6),
      ". Equivalently, divide by ",
      signif(scale_value, 6),
      "."
    ),
    diffusion_sd_conversion = paste0(
      "If diffusion is parameterized as a standard deviation or Cholesky ",
      "factor, convert from CT-scaled units back to per ",
      units,
      " by multiplying by ",
      signif(diffusion_sd_ct_to_original_multiplier, 6),
      ". Equivalently, divide by sqrt(",
      signif(scale_value, 6),
      ")."
    )
  )

  rownames(data) <- NULL
  data
}
