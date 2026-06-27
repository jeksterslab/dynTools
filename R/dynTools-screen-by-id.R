#' Screen IDs Using Dynamic-Data Diagnostics
#'
#' The function computes ID-level diagnostics, applies rule-based flags, and
#' returns IDs that are candidates for exclusion or sensitivity analysis. It is
#' a wrapper around [DiagnosticsByID()], [FlagDiagnosticsByID()], and
#' [GetDropID()].
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @inheritParams DiagnosticsByID
#' @inheritParams FlagDiagnosticsByID
#' @param flag_extreme_cut Positive number.
#'   Absolute-value cutoff used by [FlagDiagnosticsByID()]. This value is added
#'   to `extreme_cut` before calling [DiagnosticsByID()] so that the required
#'   total-count column is available.
#' @param flagged_only Logical.
#'   If `TRUE`, return IDs marked as sensitivity-drop candidates. If `FALSE`,
#'   return all flagged IDs.
#'
#' @return Returns a list with the following elements:
#' \describe{
#'   \item{\code{diagnostics}}{Diagnostics with flag columns appended.}
#'   \item{\code{drop_id}}{IDs selected by [GetDropID()].}
#'   \item{\code{keep_id}}{IDs not in `drop_id`.}
#'   \item{\code{call}}{The matched call.}
#' }
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 1, 2, 2, 2),
#'   time = c(1, 2, 3, 1, 2, 3),
#'   y1 = c(1, NA, 3, 1, 1, 1),
#'   y2 = c(NA, NA, 4, 2, 2, 2)
#' )
#'
#' ScreenByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = c("y1", "y2"),
#'   min_observed_rows = 3,
#'   min_sd = 0.05
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
ScreenByID <- function(data,
                       id,
                       time,
                       observed,
                       covariates = NULL,
                       missing_codes = NULL,
                       min_nonmissing = 1L,
                       extreme_cut = c(4, 5, 6),
                       sd_cut = c(0.10, 0.05),
                       time_scale = 1,
                       posix_unit = "hours",
                       min_observed_rows = 30L,
                       min_complete_rows = NULL,
                       max_prop_all_missing = 0.95,
                       max_gap = NULL,
                       max_median_gap = NULL,
                       min_sd = 0.05,
                       flag_extreme_cut = 6,
                       drop_score_cut = 2L,
                       flagged_only = TRUE) {
  if (
    !is.numeric(flag_extreme_cut) ||
      length(flag_extreme_cut) != 1L ||
      is.na(flag_extreme_cut) ||
      !is.finite(flag_extreme_cut) ||
      flag_extreme_cut <= 0
  ) {
    stop(
      "`flag_extreme_cut` must be a positive number.",
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

  extreme_cut <- sort(
    unique(
      c(
        extreme_cut,
        flag_extreme_cut
      )
    )
  )

  diagnostics <- DiagnosticsByID(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates,
    missing_codes = missing_codes,
    min_nonmissing = min_nonmissing,
    extreme_cut = extreme_cut,
    sd_cut = sd_cut,
    time_scale = time_scale,
    posix_unit = posix_unit
  )

  diagnostics <- FlagDiagnosticsByID(
    x = diagnostics,
    min_observed_rows = min_observed_rows,
    min_complete_rows = min_complete_rows,
    max_prop_all_missing = max_prop_all_missing,
    max_gap = max_gap,
    max_median_gap = max_median_gap,
    min_sd = min_sd,
    extreme_cut = flag_extreme_cut,
    drop_score_cut = drop_score_cut
  )

  drop_id <- GetDropID(
    x = diagnostics,
    flagged_only = flagged_only
  )

  keep_id <- setdiff(
    x = unique(data[[id]]),
    y = drop_id
  )

  out <- list(
    diagnostics = diagnostics,
    drop_id = drop_id,
    keep_id = keep_id,
    call = match.call()
  )

  class(out) <- "dynToolsScreenByID"
  out
}
