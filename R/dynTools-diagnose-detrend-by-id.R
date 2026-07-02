#' Diagnose Detrended Variables by ID
#'
#' The function computes post-detrending diagnostics by ID for observed
#' variables. It is intended to be used after detrending and before within-ID
#' scaling. The function reports within-ID variability, missingness, non-finite
#' values, and the largest standardized value that would be produced by
#' within-ID scaling.
#'
#' This is useful for identifying ID-variable combinations that may produce
#' very large standardized values because of outlying detrended observations or
#' very small within-ID variability.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param sd_min Numeric scalar or `NULL`.
#'   Minimum acceptable within-ID standard deviation after detrending.
#'   If `NULL`, low-SD flagging is skipped.
#' @param z_cut Numeric scalar.
#'   Absolute standardized-value threshold used to flag potentially extreme
#'   values after within-ID scaling.
#' @param min_n Positive integer.
#'   Minimum number of finite observations required within each ID-variable
#'   combination.
#' @param flagged_only Logical.
#'   If `TRUE`, return only flagged ID-variable combinations.
#'   If `FALSE`, return all ID-variable combinations.
#'
#' @return Returns a data frame with one row per ID-variable combination.
#'
#' @examples
#' data <- data.frame(
#'   id = rep(1:2, each = 5),
#'   time = rep(1:5, times = 2),
#'   y1 = c(1, 2, 3, 4, 20, 2, 2, 2, 2, 2),
#'   y2 = c(5, 4, 3, 2, 1, 1, 1, 1, 1, 2)
#' )
#'
#' DiagnoseDetrendByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = c("y1", "y2"),
#'   z_cut = 3
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
DiagnoseDetrendByID <- function(data,
                                id,
                                time,
                                observed,
                                sd_min = 0.10,
                                z_cut = 6,
                                min_n = 3L,
                                flagged_only = FALSE) {
  CheckDynData(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = NULL,
    require_unique = FALSE,
    require_numeric_time = TRUE,
    require_numeric_observed = TRUE,
    require_numeric_covariates = FALSE,
    min_rows = 1L
  )

  if (!is.null(sd_min)) {
    if (
      !is.numeric(sd_min) ||
        length(sd_min) != 1L ||
        is.na(sd_min) ||
        !is.finite(sd_min) ||
        sd_min < 0
    ) {
      stop(
        paste(
          "`sd_min` must be `NULL` or a non-negative finite",
          "numeric scalar."
        ),
        call. = FALSE
      )
    }
  }

  if (
    !is.numeric(z_cut) ||
      length(z_cut) != 1L ||
      is.na(z_cut) ||
      !is.finite(z_cut) ||
      z_cut <= 0
  ) {
    stop(
      "`z_cut` must be a positive finite numeric scalar.",
      call. = FALSE
    )
  }

  if (
    !is.numeric(min_n) ||
      length(min_n) != 1L ||
      is.na(min_n) ||
      !is.finite(min_n) ||
      min_n < 1L ||
      min_n != as.integer(min_n)
  ) {
    stop(
      "`min_n` must be a positive integer.",
      call. = FALSE
    )
  }

  if (
    !is.logical(flagged_only) ||
      length(flagged_only) != 1L ||
      is.na(flagged_only)
  ) {
    stop(
      "`flagged_only` must be `TRUE` or `FALSE`.",
      call. = FALSE
    )
  }

  min_n <- as.integer(min_n)

  data <- .DynToolsSelectSort(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = NULL
  )

  ids <- unique(
    data[[id]]
  )

  out <- vector(
    mode = "list",
    length = length(ids) * length(observed)
  )

  count <- 0L

  for (id_value in ids) {
    index_id <- which(
      data[[id]] == id_value
    )

    for (var in observed) {
      count <- count + 1L

      y <- data[[var]][index_id]
      t <- data[[time]][index_id]

      n_total <- length(y)
      n_na <- sum(is.na(y))
      n_nan <- sum(is.nan(y))
      n_inf <- sum(is.infinite(y))

      ok <- !is.na(y) & is.finite(y)

      n_finite <- sum(ok)
      n_missing <- n_total - n_finite

      mean_y <- NA_real_
      sd_y <- NA_real_
      min_y <- NA_real_
      max_y <- NA_real_
      range_y <- NA_real_
      max_abs_y <- NA_real_
      min_z <- NA_real_
      max_z <- NA_real_
      max_abs_z <- NA_real_
      time_max_abs_z <- NA_real_
      value_max_abs_z <- NA_real_
      row_max_abs_z <- NA_integer_

      if (n_finite > 0L) {
        y_ok <- y[ok]
        t_ok <- t[ok]
        row_ok <- index_id[ok]

        mean_y <- mean(
          x = y_ok
        )

        min_y <- min(
          y_ok
        )

        max_y <- max(
          y_ok
        )

        range_y <- max_y - min_y

        max_abs_y <- max(
          abs(y_ok)
        )

        if (n_finite > 1L) {
          sd_y <- stats::sd(
            x = y_ok
          )
        }

        if (
          n_finite > 1L &&
            !is.na(sd_y) &&
            is.finite(sd_y) &&
            sd_y > 0
        ) {
          z <- (y_ok - mean_y) / sd_y

          min_z <- min(
            z
          )

          max_z <- max(
            z
          )

          max_abs_z <- max(
            abs(z)
          )

          which_max <- which.max(
            abs(z)
          )

          time_max_abs_z <- t_ok[
            which_max
          ]

          value_max_abs_z <- y_ok[
            which_max
          ]

          row_max_abs_z <- row_ok[
            which_max
          ]
        } else if (
          n_finite > 1L &&
            !is.na(sd_y) &&
            is.finite(sd_y) &&
            sd_y == 0
        ) {
          min_z <- 0
          max_z <- 0
          max_abs_z <- 0
          time_max_abs_z <- t_ok[1L]
          value_max_abs_z <- y_ok[1L]
          row_max_abs_z <- row_ok[1L]
        }
      }

      flag_low_n <- n_finite < min_n

      flag_nonfinite <- n_nan > 0L ||
        n_inf > 0L

      flag_zero_sd <- !is.na(sd_y) &&
        is.finite(sd_y) &&
        sd_y == 0

      if (is.null(sd_min)) {
        flag_low_sd <- FALSE
      } else {
        flag_low_sd <- !is.na(sd_y) &&
          is.finite(sd_y) &&
          sd_y > 0 &&
          sd_y < sd_min
      }

      flag_extreme_z <- !is.na(max_abs_z) &&
        is.finite(max_abs_z) &&
        max_abs_z >= z_cut

      flag <- flag_low_n ||
        flag_nonfinite ||
        flag_zero_sd ||
        flag_low_sd ||
        flag_extreme_z

      out[[count]] <- data.frame(
        id = id_value,
        variable = var,
        n_total = n_total,
        n_finite = n_finite,
        n_missing = n_missing,
        n_na = n_na,
        n_nan = n_nan,
        n_inf = n_inf,
        mean = mean_y,
        sd = sd_y,
        min = min_y,
        max = max_y,
        range = range_y,
        max_abs = max_abs_y,
        min_z_after_scaling = min_z,
        max_z_after_scaling = max_z,
        max_abs_z_after_scaling = max_abs_z,
        time_max_abs_z = time_max_abs_z,
        value_max_abs_z = value_max_abs_z,
        row_max_abs_z = row_max_abs_z,
        flag_low_n = flag_low_n,
        flag_nonfinite = flag_nonfinite,
        flag_zero_sd = flag_zero_sd,
        flag_low_sd = flag_low_sd,
        flag_extreme_z = flag_extreme_z,
        flag = flag,
        stringsAsFactors = FALSE
      )
    }
  }

  out <- do.call(
    what = rbind,
    args = out
  )

  if (flagged_only) {
    out <- out[
      out$flag, ,
      drop = FALSE
    ]
  }

  rownames(out) <- NULL
  out
}
