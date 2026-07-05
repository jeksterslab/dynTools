#' Flag Potentially Problematic IDs
#'
#' The function adds rule-based flags to the output of [DiagnosticsByID()].
#' It is intended for sensitivity checks before fitting dynamic models.
#' It flags low observation counts, missingness, duplicate ID-time rows,
#' non-finite observed values, large time gaps, low variability, and extreme
#' observed values.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param x Data frame returned by [DiagnosticsByID()].
#' @param min_observed_rows Positive integer.
#' Minimum number of observed rows expected per ID.
#' @param min_complete_rows `NULL` or positive integer.
#' Minimum number of complete rows expected per ID.
#' @param max_prop_all_missing `NULL` or number between 0 and 1.
#' Maximum tolerated proportion of all-missing observed rows.
#' @param max_gap `NULL` or positive number.
#' Maximum tolerated observed-row time gap in the units used by
#' [DiagnosticsByID()].
#' @param max_median_gap `NULL` or positive number.
#' Maximum tolerated median observed-row time gap in the units used by
#' [DiagnosticsByID()].
#' @param min_sd `NULL` or non-negative number.
#' Minimum tolerated within-ID standard deviation across observed variables.
#' If `NULL`, low-SD flagging is skipped.
#' @param extreme_cut Positive number.
#' Absolute-value cutoff used to flag extreme observations.
#' @param drop_score_cut Positive integer.
#' IDs with priority scores greater than or equal to this value are marked as
#' sensitivity-drop candidates.
#'
#' @return Returns `x` with flag columns appended.
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 1, 2, 2, 2),
#'   time = c(1, 2, 3, 1, 2, 3),
#'   y1 = c(1, NA, 3, 1, 1, 1),
#'   y2 = c(NA, NA, 4, 2, 2, 2)
#' )
#'
#' diagnostics <- DiagnosticsByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = c("y1", "y2")
#' )
#'
#' FlagDiagnosticsByID(
#'   x = diagnostics,
#'   min_observed_rows = 3,
#'   min_sd = 0.05
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
FlagDiagnosticsByID <- function(x,
                                min_observed_rows = 30L,
                                min_complete_rows = NULL,
                                max_prop_all_missing = 0.95,
                                max_gap = NULL,
                                max_median_gap = NULL,
                                min_sd = 0.05,
                                extreme_cut = 6,
                                drop_score_cut = 2L) {
  if (!is.data.frame(x)) {
    stop(
      "`x` must be a data frame returned by `DiagnosticsByID()`.",
      call. = FALSE
    )
  }

  required <- c(
    "id",
    "n_observed_rows",
    "n_complete_rows",
    "prop_all_missing",
    "max_obs_gap",
    "median_obs_gap",
    "min_sd",
    "n_duplicate_id_time",
    "n_nonfinite_total"
  )

  missing <- setdiff(
    x = required,
    y = names(x)
  )

  if (length(missing) > 0L) {
    stop(
      paste0(
        "The following required columns are missing from `x`: ",
        paste(missing, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  if (
    !is.numeric(min_observed_rows) ||
      length(min_observed_rows) != 1L ||
      is.na(min_observed_rows) ||
      !is.finite(min_observed_rows) ||
      min_observed_rows < 1L
  ) {
    stop(
      "`min_observed_rows` must be a positive number.",
      call. = FALSE
    )
  }

  if (!is.null(min_complete_rows)) {
    if (
      !is.numeric(min_complete_rows) ||
        length(min_complete_rows) != 1L ||
        is.na(min_complete_rows) ||
        !is.finite(min_complete_rows) ||
        min_complete_rows < 1L
    ) {
      stop(
        "`min_complete_rows` must be `NULL` or a positive number.",
        call. = FALSE
      )
    }
  }

  if (!is.null(max_prop_all_missing)) {
    if (
      !is.numeric(max_prop_all_missing) ||
        length(max_prop_all_missing) != 1L ||
        is.na(max_prop_all_missing) ||
        !is.finite(max_prop_all_missing) ||
        max_prop_all_missing < 0 ||
        max_prop_all_missing > 1
    ) {
      stop(
        "`max_prop_all_missing` must be `NULL` or a number between 0 and 1.",
        call. = FALSE
      )
    }
  }

  if (!is.null(max_gap)) {
    if (
      !is.numeric(max_gap) ||
        length(max_gap) != 1L ||
        is.na(max_gap) ||
        !is.finite(max_gap) ||
        max_gap <= 0
    ) {
      stop(
        "`max_gap` must be `NULL` or a positive number.",
        call. = FALSE
      )
    }
  }

  if (!is.null(max_median_gap)) {
    if (
      !is.numeric(max_median_gap) ||
        length(max_median_gap) != 1L ||
        is.na(max_median_gap) ||
        !is.finite(max_median_gap) ||
        max_median_gap <= 0
    ) {
      stop(
        "`max_median_gap` must be `NULL` or a positive number.",
        call. = FALSE
      )
    }
  }

  if (!is.null(min_sd)) {
    if (
      !is.numeric(min_sd) ||
        length(min_sd) != 1L ||
        is.na(min_sd) ||
        !is.finite(min_sd) ||
        min_sd < 0
    ) {
      stop(
        "`min_sd` must be `NULL` or a non-negative number.",
        call. = FALSE
      )
    }
  }

  if (
    !is.numeric(extreme_cut) ||
      length(extreme_cut) != 1L ||
      is.na(extreme_cut) ||
      !is.finite(extreme_cut) ||
      extreme_cut <= 0
  ) {
    stop(
      "`extreme_cut` must be a positive number.",
      call. = FALSE
    )
  }

  if (
    !is.numeric(drop_score_cut) ||
      length(drop_score_cut) != 1L ||
      is.na(drop_score_cut) ||
      !is.finite(drop_score_cut) ||
      drop_score_cut < 1L
  ) {
    stop(
      "`drop_score_cut` must be a positive number.",
      call. = FALSE
    )
  }

  extreme_col <- paste0(
    "n_abs_gt",
    .DynToolsSafeCut(extreme_cut),
    "_total"
  )

  if (!extreme_col %in% names(x)) {
    stop(
      paste0(
        "Column `",
        extreme_col,
        "` is missing. Re-run `DiagnosticsByID()` with `extreme_cut = ",
        extreme_cut,
        "`."
      ),
      call. = FALSE
    )
  }

  x$flag_low_observed_rows <- x$n_observed_rows < min_observed_rows

  x$flag_low_complete_rows <- if (is.null(min_complete_rows)) {
    FALSE
  } else {
    x$n_complete_rows < min_complete_rows
  }

  x$flag_mostly_all_missing <- if (is.null(max_prop_all_missing)) {
    FALSE
  } else {
    x$prop_all_missing > max_prop_all_missing
  }

  x$flag_large_gap <- if (is.null(max_gap)) {
    FALSE
  } else {
    x$max_obs_gap > max_gap
  }

  x$flag_large_median_gap <- if (is.null(max_median_gap)) {
    FALSE
  } else {
    x$median_obs_gap > max_median_gap
  }

  x$flag_low_sd <- if (is.null(min_sd)) {
    FALSE
  } else {
    x$min_sd < min_sd
  }

  x$flag_duplicate_id_time <- x$n_duplicate_id_time > 0L
  x$flag_nonfinite <- x$n_nonfinite_total > 0L
  x$flag_extreme <- x[[extreme_col]] > 0L

  flag_names <- c(
    "flag_low_observed_rows",
    "flag_low_complete_rows",
    "flag_mostly_all_missing",
    "flag_large_gap",
    "flag_large_median_gap",
    "flag_low_sd",
    "flag_duplicate_id_time",
    "flag_nonfinite",
    "flag_extreme"
  )

  x$priority_score <- rowSums(
    x[flag_names],
    na.rm = TRUE
  )

  x$flag_any <- x$priority_score > 0L

  x$drop_sensitivity_candidate <- x$flag_low_observed_rows |
    x$flag_low_complete_rows |
    x$flag_low_sd |
    x$priority_score >= drop_score_cut

  x$flag_reason <- vapply(
    X = seq_len(nrow(x)),
    FUN = function(i) {
      reason <- character(0)

      if (isTRUE(x$flag_low_observed_rows[i])) {
        reason <- c(
          reason,
          paste0("n_obs_lt_", min_observed_rows)
        )
      }

      if (isTRUE(x$flag_low_complete_rows[i])) {
        reason <- c(
          reason,
          paste0("n_complete_lt_", min_complete_rows)
        )
      }

      if (isTRUE(x$flag_mostly_all_missing[i])) {
        reason <- c(
          reason,
          paste0("prop_all_missing_gt_", max_prop_all_missing)
        )
      }

      if (isTRUE(x$flag_large_gap[i])) {
        reason <- c(
          reason,
          paste0("max_gap_gt_", max_gap)
        )
      }

      if (isTRUE(x$flag_large_median_gap[i])) {
        reason <- c(
          reason,
          paste0("median_gap_gt_", max_median_gap)
        )
      }

      if (isTRUE(x$flag_low_sd[i])) {
        reason <- c(
          reason,
          paste0("sd_lt_", min_sd)
        )
      }

      if (isTRUE(x$flag_duplicate_id_time[i])) {
        reason <- c(
          reason,
          "duplicate_id_time"
        )
      }

      if (isTRUE(x$flag_nonfinite[i])) {
        reason <- c(
          reason,
          "nonfinite_observed"
        )
      }

      if (isTRUE(x$flag_extreme[i])) {
        reason <- c(
          reason,
          paste0("extreme_abs_gt_", extreme_cut)
        )
      }

      if (length(reason) == 0L) {
        ""
      } else {
        paste(reason, collapse = ";")
      }
    },
    FUN.VALUE = character(1)
  )

  x
}
