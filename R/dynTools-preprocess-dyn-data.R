#' Preprocess Intensive Longitudinal Data for Dynamic Modeling
#'
#' The function implements a reproducible preprocessing workflow for intensive
#' longitudinal data before dynamic model fitting. The workflow can replace
#' missing-value codes, construct a date-time variable, resolve exact duplicate
#' ID-time rows, remove initial all-missing rows, create elapsed time by ID,
#' compute ID-level diagnostics, optionally drop flagged IDs, optionally insert
#' missing rows on a regular grid, detrend observed variables by ID, and center
#' or standardize observed variables by ID.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param data Data frame.
#' @param id Character string.
#'   Name of the ID variable.
#' @param observed Character vector.
#'   Names of observed variables to preprocess.
#' @param covariates Character vector or `NULL`.
#'   Names of covariates to retain and optionally center or scale.
#' @param date Character string or `NULL`.
#'   Name of the date variable. Use with `clock_time` to construct clock time.
#' @param clock_time Character string or `NULL`.
#'   Name of the within-day clock-time variable. Use with `date`.
#' @param time Character string or `NULL`.
#'   Name of an existing time variable. Used when `date` and `clock_time` are
#'   not supplied.
#' @param tz Character string.
#'   Time zone passed to [MakeClockTime()].
#' @param date_formats Character vector.
#'   Date formats passed to [MakeClockTime()].
#' @param invalid Character string.
#'   Invalid clock-time handling passed to [MakeClockTime()].
#' @param datetime_output Character string.
#'   Name of the constructed `POSIXct` date-time variable when `date` and
#'   `clock_time` are supplied.
#' @param raw_time_output Character string.
#'   Name of the numeric raw-time variable used for duplicate resolution.
#' @param output_time Character string.
#'   Name of the elapsed-time variable used for modeling.
#' @param missing_codes `NULL` or vector.
#'   Missing-value codes to replace with `NA`.
#' @param missing_columns Character vector or `NULL`.
#'   Columns where missing-value codes should be replaced. If `NULL`, the
#'   replacement is applied to `observed` and `covariates`.
#' @param drop_missing_time Logical.
#'   If `TRUE`, remove rows with missing constructed/raw time before duplicate
#'   resolution.
#' @param duplicate_method Character string.
#'   Method passed to [ResolveDuplicateIDTime()].
#' @param delete_initial_na Logical.
#'   If `TRUE`, remove leading rows with too few observed values within ID.
#' @param initial_min_nonmissing Positive integer.
#'   Minimum number of non-missing observed variables required in the first
#'   retained row within ID. Use `length(observed)` to mimic the stricter
#'   behavior of [DeleteInitialNA()].
#' @param elapsed_units Character string.
#'   Units for elapsed time passed to [ElapsedTimeByID()].
#' @param elapsed_origin Character string.
#'   Origin passed to [ElapsedTimeByID()].
#' @param elapsed_input_units Character string or `NULL`.
#'   Units of numeric raw time passed to [ElapsedTimeByID()].
#' @param screen Logical.
#'   If `TRUE`, compute ID-level diagnostics and drop candidates before optional
#'   regularization, detrending, and scaling.
#' @param drop_id Vector or `NULL`.
#'   IDs to remove regardless of diagnostic flags.
#' @param drop_flagged Logical.
#'   If `TRUE`, remove IDs selected by [ScreenByID()]. If `FALSE`, return the
#'   candidates but keep them in the processed data.
#' @param min_observed_rows Positive number.
#'   Minimum number of rows with at least `min_nonmissing` observed variables
#'   required for each ID. Passed to [ScreenByID()].
#' @param min_complete_rows Positive number or `NULL`.
#'   Minimum number of complete observed rows required for each ID. Passed to
#'   [ScreenByID()].
#' @param max_prop_all_missing Numeric value in `[0, 1]` or `NULL`.
#'   Maximum allowed proportion of rows with all observed variables missing for
#'   each ID. Passed to [ScreenByID()].
#' @param max_gap Positive number or `NULL`.
#'   Maximum allowed observed-time gap for each ID. Passed to [ScreenByID()].
#' @param max_median_gap Positive number or `NULL`.
#'   Maximum allowed median observed-time gap for each ID. Passed to
#'   [ScreenByID()].
#' @param min_sd Non-negative number or `NULL`.
#'   Minimum allowed within-ID standard deviation across observed variables.
#'   Passed to [ScreenByID()].
#' @param flag_extreme_cut Positive number.
#'   Absolute standardized-value cutoff used to flag extreme values. Passed to
#'   [ScreenByID()].
#' @param drop_score_cut Positive number.
#'   Priority-score cutoff used by [ScreenByID()] when `flagged_only = TRUE`.
#' @param min_nonmissing Positive integer.
#'   Minimum number of non-missing observed variables defining an observed row.
#'   Passed to [ScreenByID()].
#' @param extreme_cut Numeric vector.
#'   Extreme-value cut points used by [ScreenByID()].
#' @param sd_cut Numeric vector.
#'   Low-variability cut points used by [ScreenByID()].
#' @param screen_time_scale Positive number.
#'   Multiplier applied to time gaps in [ScreenByID()].
#' @param posix_unit Character string.
#'   Unit used for `POSIXct` time-gap calculations in [ScreenByID()].
#' @param regularize Logical.
#'   If `TRUE`, call [RegularizeTimeByID()]. Continuous-time models that handle
#'   unequal intervals usually do not require this step.
#' @param delta_t Positive number or `NULL`.
#'   Time interval passed to [RegularizeTimeByID()] when `regularize = TRUE`.
#' @param grid Character string.
#'   Grid type passed to [RegularizeTimeByID()].
#' @param regularize_method Character string.
#'   Method passed to [RegularizeTimeByID()].
#' @param detrend Logical.
#'   If `TRUE`, call [DetrendByID()].
#' @param degree Non-negative integer.
#'   Polynomial degree passed to [DetrendByID()].
#' @param keep_mean Logical.
#'   Passed to [DetrendByID()].
#' @param warn_skipped Logical.
#'   Passed to [DetrendByID()].
#' @param drop_skipped_ids Logical.
#'   Passed to [DetrendByID()].
#' @param center Logical.
#'   If `TRUE`, call [ScaleByID()].
#' @param scale Logical.
#'   If `TRUE`, standardize by ID. If `FALSE`, only mean-center by ID. Ignored
#'   when `center = FALSE`.
#' @param obs_skip,cov_skip Character vectors or `NULL`.
#'   Variables to skip when centering or scaling.
#' @param keep_raw_time Logical.
#'   If `FALSE`, remove `raw_time_output` from the returned data.
#' @param keep_datetime Logical.
#'   If `FALSE`, remove `datetime_output` from the returned data.
#' @param final_diagnostics Logical.
#'   If `TRUE`, compute diagnostics on the final processed data.
#' @param return_list Logical.
#'   If `TRUE`, return a list with data, diagnostics, and dropped IDs. If
#'   `FALSE`, return only the processed data.
#'
#' @return If `return_list = TRUE`, returns a list with elements `data`,
#' `diagnostics`, `final_diagnostics`, `drop_id`, `flagged_id`, `manual_drop_id`,
#' and `call`. If `return_list = FALSE`, returns the processed data frame.
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 1, 2, 2, 2),
#'   date = rep("2020-01-01", 6),
#'   clock = c("08:00", "09:00", "10:00", "08:00", "09:00", "10:00"),
#'   y1 = c(1, NA, 3, 1, 1, 1),
#'   y2 = c(NA, 2, 4, 2, 2, 2)
#' )
#'
#' PreprocessDynData(
#'   data = data,
#'   id = "id",
#'   date = "date",
#'   clock_time = "clock",
#'   observed = c("y1", "y2"),
#'   min_observed_rows = 3,
#'   detrend = FALSE,
#'   center = FALSE
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
PreprocessDynData <- function(data,
                              id,
                              observed,
                              covariates = NULL,
                              date = NULL,
                              clock_time = NULL,
                              time = NULL,
                              tz = "UTC",
                              date_formats = c(
                                "%m/%d/%y",
                                "%m/%d/%Y",
                                "%Y-%m-%d"
                              ),
                              invalid = c("NA", "error"),
                              datetime_output = "time_obs",
                              raw_time_output = "time_raw",
                              output_time = "time",
                              missing_codes = c(-999, "-999"),
                              missing_columns = NULL,
                              drop_missing_time = TRUE,
                              duplicate_method = c(
                                "max_complete",
                                "first",
                                "last"
                              ),
                              delete_initial_na = TRUE,
                              initial_min_nonmissing = 1L,
                              elapsed_units = "days",
                              elapsed_origin = c("by_id", "global"),
                              elapsed_input_units = NULL,
                              screen = TRUE,
                              drop_id = NULL,
                              drop_flagged = FALSE,
                              min_observed_rows = 30L,
                              min_complete_rows = NULL,
                              max_prop_all_missing = 0.95,
                              max_gap = NULL,
                              max_median_gap = NULL,
                              min_sd = 0.05,
                              flag_extreme_cut = 6,
                              drop_score_cut = 2L,
                              min_nonmissing = 1L,
                              extreme_cut = c(4, 5, 6),
                              sd_cut = c(0.10, 0.05),
                              screen_time_scale = 24,
                              posix_unit = "hours",
                              regularize = FALSE,
                              delta_t = NULL,
                              grid = c("by_id", "global"),
                              regularize_method = c("preserve", "snap"),
                              detrend = TRUE,
                              degree = 1L,
                              keep_mean = TRUE,
                              warn_skipped = TRUE,
                              drop_skipped_ids = TRUE,
                              center = TRUE,
                              scale = TRUE,
                              obs_skip = NULL,
                              cov_skip = NULL,
                              keep_raw_time = FALSE,
                              keep_datetime = TRUE,
                              final_diagnostics = TRUE,
                              return_list = TRUE) {
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
    !is.character(observed) ||
      length(observed) == 0L ||
      any(is.na(observed)) ||
      any(observed == "")
  ) {
    stop(
      "`observed` must be a non-empty character vector.",
      call. = FALSE
    )
  }

  if (
    !is.null(covariates) &&
      (
        !is.character(covariates) ||
          any(is.na(covariates)) ||
          any(covariates == "")
      )
  ) {
    stop(
      "`covariates` must be `NULL` or a character vector.",
      call. = FALSE
    )
  }

  if (
    !is.logical(drop_missing_time) ||
      length(drop_missing_time) != 1L ||
      is.na(drop_missing_time)
  ) {
    stop(
      "`drop_missing_time` must be `TRUE` or `FALSE`.",
      call. = FALSE
    )
  }

  logical_args <- c(
    screen = screen,
    drop_flagged = drop_flagged,
    regularize = regularize,
    detrend = detrend,
    keep_mean = keep_mean,
    warn_skipped = warn_skipped,
    drop_skipped_ids = drop_skipped_ids,
    center = center,
    scale = scale,
    keep_raw_time = keep_raw_time,
    keep_datetime = keep_datetime,
    final_diagnostics = final_diagnostics,
    return_list = return_list
  )

  bad_logical <- names(logical_args)[
    is.na(logical_args)
  ]

  if (length(bad_logical) > 0L) {
    stop(
      paste0(
        "The following arguments must be `TRUE` or `FALSE`: ",
        paste(bad_logical, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  invalid <- match.arg(invalid)
  duplicate_method <- match.arg(duplicate_method)
  elapsed_origin <- match.arg(elapsed_origin)
  grid <- match.arg(grid)
  regularize_method <- match.arg(regularize_method)

  if (regularize) {
    if (
      !is.numeric(delta_t) ||
        length(delta_t) != 1L ||
        is.na(delta_t) ||
        !is.finite(delta_t) ||
        delta_t <= 0
    ) {
      stop(
        "`delta_t` must be a positive finite number when `regularize = TRUE`.",
        call. = FALSE
      )
    }
  }

  use_clock <- !is.null(date) || !is.null(clock_time)

  if (use_clock) {
    if (
      is.null(date) ||
        is.null(clock_time) ||
        !is.character(date) ||
        !is.character(clock_time) ||
        length(date) != 1L ||
        length(clock_time) != 1L ||
        is.na(date) ||
        is.na(clock_time) ||
        date == "" ||
        clock_time == ""
    ) {
      stop(
        "`date` and `clock_time` must both be non-empty character strings.",
        call. = FALSE
      )
    }
  } else if (
    is.null(time) ||
      !is.character(time) ||
      length(time) != 1L ||
      is.na(time) ||
      time == ""
  ) {
    stop(
      "Supply either `date` and `clock_time`, or an existing `time` variable.",
      call. = FALSE
    )
  }

  original_time <- if (use_clock) {
    c(date, clock_time)
  } else {
    time
  }

  keep_vars <- unique(
    c(
      id,
      original_time,
      observed,
      covariates
    )
  )

  missing_vars <- setdiff(
    x = keep_vars,
    y = names(data)
  )

  if (length(missing_vars) > 0L) {
    stop(
      paste0(
        "The following variables are missing from `data`: ",
        paste(missing_vars, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  data <- data[
    ,
    keep_vars,
    drop = FALSE
  ]

  if (is.null(missing_columns)) {
    missing_columns <- unique(
      c(
        observed,
        covariates
      )
    )
  }

  data <- ReplaceMissingCode(
    data = data,
    values = missing_codes,
    columns = missing_columns
  )

  if (use_clock) {
    data[[datetime_output]] <- MakeClockTime(
      date = data[[date]],
      time = data[[clock_time]],
      tz = tz,
      date_formats = date_formats,
      invalid = invalid
    )

    data[[raw_time_output]] <- as.numeric(
      data[[datetime_output]]
    )

    elapsed_input_units_use <- if (is.null(elapsed_input_units)) {
      "secs"
    } else {
      elapsed_input_units
    }
  } else {
    if (inherits(data[[time]], "POSIXt") || inherits(data[[time]], "Date")) {
      data[[datetime_output]] <- as.POSIXct(
        data[[time]],
        tz = tz
      )
      data[[raw_time_output]] <- as.numeric(
        data[[datetime_output]]
      )
      elapsed_input_units_use <- if (is.null(elapsed_input_units)) {
        "secs"
      } else {
        elapsed_input_units
      }
    } else {
      data[[raw_time_output]] <- data[[time]]
      elapsed_input_units_use <- elapsed_input_units
    }
  }

  if (drop_missing_time) {
    data <- data[
      !is.na(data[[raw_time_output]]), ,
      drop = FALSE
    ]
  }

  data <- ResolveDuplicateIDTime(
    data = data,
    id = id,
    time = raw_time_output,
    observed = observed,
    covariates = covariates,
    method = duplicate_method
  )

  if (delete_initial_na) {
    data <- TrimInitialRowsByID(
      data = data,
      id = id,
      time = raw_time_output,
      observed = observed,
      covariates = covariates,
      min_nonmissing = initial_min_nonmissing
    )
  }

  data <- ElapsedTimeByID(
    data = data,
    id = id,
    time = raw_time_output,
    output = output_time,
    units = elapsed_units,
    origin = elapsed_origin,
    input_units = elapsed_input_units_use,
    replace = FALSE
  )

  diagnostics <- NULL
  flagged_id <- NULL

  if (screen) {
    screen_out <- ScreenByID(
      data = data,
      id = id,
      time = output_time,
      observed = observed,
      covariates = covariates,
      missing_codes = NULL,
      min_nonmissing = min_nonmissing,
      extreme_cut = extreme_cut,
      sd_cut = sd_cut,
      time_scale = screen_time_scale,
      posix_unit = posix_unit,
      min_observed_rows = min_observed_rows,
      min_complete_rows = min_complete_rows,
      max_prop_all_missing = max_prop_all_missing,
      max_gap = max_gap,
      max_median_gap = max_median_gap,
      min_sd = min_sd,
      flag_extreme_cut = flag_extreme_cut,
      drop_score_cut = drop_score_cut,
      flagged_only = TRUE
    )

    diagnostics <- screen_out$diagnostics
    flagged_id <- screen_out$drop_id
  }

  manual_drop_id <- drop_id
  all_drop_id <- unique(
    c(
      manual_drop_id,
      if (drop_flagged) flagged_id else NULL
    )
  )

  if (length(all_drop_id) > 0L) {
    data <- DropByID(
      data = data,
      id = id,
      drop = all_drop_id
    )
  }

  if (regularize) {
    data <- RegularizeTimeByID(
      data = data,
      id = id,
      time = output_time,
      observed = observed,
      covariates = covariates,
      delta_t = delta_t,
      grid = grid,
      method = regularize_method
    )
  }

  if (detrend) {
    data <- DetrendByID(
      data = data,
      id = id,
      time = output_time,
      observed = observed,
      covariates = covariates,
      degree = degree,
      replace = TRUE,
      keep_mean = keep_mean,
      warn_skipped = warn_skipped,
      drop_skipped_ids = drop_skipped_ids
    )
  }

  if (center) {
    data <- ScaleByID(
      data = data,
      id = id,
      time = output_time,
      observed = observed,
      covariates = covariates,
      scale = scale,
      obs_skip = obs_skip,
      cov_skip = cov_skip
    )
  } else {
    data <- .DynToolsSelectSort(
      data = data,
      id = id,
      time = output_time,
      observed = observed,
      covariates = covariates
    )
  }

  if (!keep_raw_time && raw_time_output %in% names(data)) {
    data[[raw_time_output]] <- NULL
  }

  if (!keep_datetime && datetime_output %in% names(data)) {
    data[[datetime_output]] <- NULL
  }

  diagnostics_final <- NULL

  if (final_diagnostics && nrow(data) > 0L) {
    diagnostics_final <- DiagnosticsByID(
      data = data,
      id = id,
      time = output_time,
      observed = observed,
      covariates = covariates,
      missing_codes = NULL,
      min_nonmissing = min_nonmissing,
      extreme_cut = extreme_cut,
      sd_cut = sd_cut,
      time_scale = screen_time_scale,
      posix_unit = posix_unit
    )
  }

  rownames(data) <- NULL

  if (!return_list) {
    return(data)
  }

  out <- list(
    data = data,
    diagnostics = diagnostics,
    final_diagnostics = diagnostics_final,
    drop_id = all_drop_id,
    flagged_id = flagged_id,
    manual_drop_id = manual_drop_id,
    call = match.call()
  )

  class(out) <- "dynToolsPreprocessDynData"
  out
}
