#' ID-Level Diagnostics for Dynamic Modeling Data
#'
#' The function computes ID-level diagnostics for intensive longitudinal data.
#' Diagnostics include the number of observed rows, number of complete rows,
#' proportion of all-missing observed rows, duplicate ID-time rows, time gaps,
#' within-ID standard deviations, and counts of extreme observed values.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param missing_codes `NULL` or vector.
#' Values to temporarily treat as missing when computing diagnostics.
#' The input data are not modified.
#' @param min_nonmissing Positive integer.
#' Minimum number of non-missing observed variables required for a row to count
#' as an observed row.
#' @param extreme_cut Numeric vector.
#' Absolute-value cutoffs used to count extreme values.
#' @param sd_cut Numeric vector.
#' Within-ID standard-deviation cutoffs used to count low-variance variables.
#' @param time_scale Positive number.
#' Multiplier applied to numeric time gaps. For example, use `time_scale = 24`
#' when time is measured in days and gaps should be reported in hours.
#' @param posix_unit Character string.
#' Unit for gaps when `time` is a `POSIXt` or `Date` variable. Passed to
#' `as.numeric.difftime()`.
#'
#' @return Returns a data frame with one row per ID.
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 1, 2, 2, 2),
#'   time = c(1, 2, 3, 1, 2, 3),
#'   y1 = c(1, NA, 3, 1, 1, 1),
#'   y2 = c(NA, NA, 4, 2, 2, 2)
#' )
#'
#' DiagnosticsByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = c("y1", "y2")
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
DiagnosticsByID <- function(data,
                            id,
                            time,
                            observed,
                            covariates = NULL,
                            missing_codes = NULL,
                            min_nonmissing = 1L,
                            extreme_cut = c(4, 5, 6),
                            sd_cut = c(0.10, 0.05),
                            time_scale = 1,
                            posix_unit = "hours") {
  CheckDynData(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates,
    require_unique = FALSE,
    require_numeric_time = FALSE,
    require_numeric_observed = TRUE,
    require_numeric_covariates = FALSE,
    min_rows = 1L
  )

  if (
    !is.numeric(min_nonmissing) ||
      length(min_nonmissing) != 1L ||
      is.na(min_nonmissing) ||
      !is.finite(min_nonmissing) ||
      min_nonmissing < 1L ||
      min_nonmissing != as.integer(min_nonmissing)
  ) {
    stop(
      "`min_nonmissing` must be a positive integer.",
      call. = FALSE
    )
  }

  min_nonmissing <- as.integer(min_nonmissing)

  if (min_nonmissing > length(observed)) {
    stop(
      "`min_nonmissing` must be less than or equal to `length(observed)`.",
      call. = FALSE
    )
  }

  if (
    !is.numeric(extreme_cut) ||
      length(extreme_cut) == 0L ||
      any(is.na(extreme_cut)) ||
      any(!is.finite(extreme_cut)) ||
      any(extreme_cut <= 0)
  ) {
    stop(
      "`extreme_cut` must be a positive numeric vector.",
      call. = FALSE
    )
  }

  if (
    !is.numeric(sd_cut) ||
      length(sd_cut) == 0L ||
      any(is.na(sd_cut)) ||
      any(!is.finite(sd_cut)) ||
      any(sd_cut < 0)
  ) {
    stop(
      "`sd_cut` must be a non-negative numeric vector.",
      call. = FALSE
    )
  }

  if (
    !is.numeric(time_scale) ||
      length(time_scale) != 1L ||
      is.na(time_scale) ||
      !is.finite(time_scale) ||
      time_scale <= 0
  ) {
    stop(
      "`time_scale` must be a positive number.",
      call. = FALSE
    )
  }

  if (
    !is.character(posix_unit) ||
      length(posix_unit) != 1L ||
      is.na(posix_unit) ||
      !posix_unit %in% c("auto", "secs", "mins", "hours", "days", "weeks")
  ) {
    stop(
      paste0(
        "`posix_unit` must be one of ",
        "'auto', 'secs', 'mins', 'hours', 'days', or 'weeks'."
      ),
      call. = FALSE
    )
  }

  if (!is.null(missing_codes)) {
    for (var in observed) {
      data[[var]][data[[var]] %in% missing_codes] <- NA
    }
  }

  data <- data[order(data[[id]], data[[time]]), , drop = FALSE]

  ids <- unique(data[[id]])
  out <- vector(
    mode = "list",
    length = length(ids)
  )

  extreme_cut <- sort(unique(extreme_cut))
  sd_cut <- sort(unique(sd_cut), decreasing = TRUE)

  for (i in seq_along(ids)) {
    dat_i <- data[data[[id]] == ids[i], , drop = FALSE]
    obs_mat <- !is.na(dat_i[observed])
    n_nonmissing <- rowSums(obs_mat)
    observed_row <- n_nonmissing >= min_nonmissing
    complete_row <- n_nonmissing == length(observed)

    time_i <- dat_i[[time]]
    time_obs <- time_i[observed_row]
    gap <- .DynToolsTimeGap(
      x = time_obs,
      time_scale = time_scale,
      posix_unit = posix_unit
    )

    key <- paste(dat_i[[id]], dat_i[[time]], sep = "\r")

    base_i <- data.frame(
      id = ids[i],
      n_rows = nrow(dat_i),
      n_observed_rows = sum(observed_row),
      n_complete_rows = sum(complete_row),
      prop_all_missing = mean(n_nonmissing == 0L),
      n_duplicate_id_time = sum(duplicated(key)),
      min_time = suppressWarnings(min(time_i, na.rm = TRUE)),
      max_time = suppressWarnings(max(time_i, na.rm = TRUE)),
      max_obs_gap = if (length(gap) > 0L) max(gap, na.rm = TRUE) else NA_real_,
      median_obs_gap = if (length(gap) > 0L) stats::median(gap, na.rm = TRUE) else NA_real_,
      mean_obs_gap = if (length(gap) > 0L) mean(gap, na.rm = TRUE) else NA_real_,
      stringsAsFactors = FALSE
    )

    var_i <- list()
    sd_values <- rep(NA_real_, length(observed))
    names(sd_values) <- observed
    max_abs_values <- rep(NA_real_, length(observed))
    names(max_abs_values) <- observed

    for (var in observed) {
      x <- dat_i[[var]]
      x_ok <- x[!is.na(x)]
      n_ok <- length(x_ok)
      sd_x <- if (n_ok >= 2L) stats::sd(x_ok) else NA_real_
      max_abs_x <- if (n_ok > 0L) max(abs(x_ok), na.rm = TRUE) else NA_real_

      sd_values[var] <- sd_x
      max_abs_values[var] <- max_abs_x

      prefix <- .DynToolsSafeName(var)

      var_i[[paste0("miss_", prefix)]] <- mean(is.na(x))
      var_i[[paste0("n_", prefix)]] <- n_ok
      var_i[[paste0("sd_", prefix)]] <- sd_x
      var_i[[paste0("maxabs_", prefix)]] <- max_abs_x

      for (cut in extreme_cut) {
        var_i[[paste0("n_abs_gt", .DynToolsSafeCut(cut), "_", prefix)]] <-
          sum(abs(x_ok) > cut, na.rm = TRUE)
      }
    }

    var_i <- as.data.frame(
      var_i,
      stringsAsFactors = FALSE
    )

    finite_sd <- sd_values[is.finite(sd_values)]
    finite_abs <- max_abs_values[is.finite(max_abs_values)]

    min_sd <- if (length(finite_sd) > 0L) min(finite_sd) else NA_real_
    median_sd <- if (length(finite_sd) > 0L) stats::median(finite_sd) else NA_real_
    max_abs_any <- if (length(finite_abs) > 0L) max(finite_abs) else NA_real_

    min_sd_variable <- if (length(finite_sd) > 0L) {
      names(finite_sd)[which.min(finite_sd)]
    } else {
      NA_character_
    }

    max_abs_variable <- if (length(finite_abs) > 0L) {
      names(finite_abs)[which.max(finite_abs)]
    } else {
      NA_character_
    }

    summary_i <- data.frame(
      min_sd = min_sd,
      median_sd = median_sd,
      min_sd_variable = min_sd_variable,
      max_abs_any = max_abs_any,
      max_abs_variable = max_abs_variable,
      stringsAsFactors = FALSE
    )

    for (cut in sd_cut) {
      summary_i[[paste0("n_var_sd_lt_", .DynToolsSafeCut(cut))]] <-
        sum(sd_values < cut, na.rm = TRUE)
    }

    for (cut in extreme_cut) {
      summary_i[[paste0("n_abs_gt", .DynToolsSafeCut(cut), "_total")]] <-
        sum(
          vapply(
            X = observed,
            FUN = function(var) {
              x <- dat_i[[var]]
              x <- x[!is.na(x)]
              sum(abs(x) > cut, na.rm = TRUE)
            },
            FUN.VALUE = integer(1)
          )
        )
    }

    out[[i]] <- cbind(
      base_i,
      var_i,
      summary_i
    )
  }

  out <- do.call(
    what = rbind,
    args = out
  )

  rownames(out) <- NULL
  out
}
