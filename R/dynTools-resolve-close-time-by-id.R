#' Resolve Close Time Points by ID
#'
#' The function resolves observations that occur very close together within ID.
#' Within each ID, rows are ordered by time and grouped into close-time
#' clusters. Consecutive observations belong to the same cluster when the time
#' gap between them is less than `min_gap`. One row is retained from each
#' close-time cluster.
#'
#' This is useful before fitting continuous-time models, where observations
#' that are nearly simultaneous can create numerical problems, especially when
#' the observed values change substantially over a very small time interval.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param min_gap Numeric scalar or `difftime`.
#'   Minimum allowed gap between consecutive observations within ID.
#'   For numeric `time`, `min_gap` must be a positive finite numeric scalar in
#'   the same units as `time`.
#'   For `Date` or `POSIXt` `time`, `min_gap` must be a positive `difftime`
#'   object.
#' @param method Character string.
#'   Method used to select the row retained from each close-time cluster.
#'   If `method = "max_complete"`, the row with the largest number of
#'   non-missing observed variables is retained. Ties are resolved by retaining
#'   the earliest row in the sorted data.
#'   If `method = "first"`, the first row in the cluster is retained.
#'   If `method = "last"`, the last row in the cluster is retained.
#'
#' @return Returns a data frame with close-time observations resolved within
#'   ID.
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 1, 1, 2, 2),
#'   datetime = as.POSIXct(
#'     c(
#'       "2020-01-01 00:00:00",
#'       "2020-01-01 00:02:00",
#'       "2020-01-01 01:00:00",
#'       "2020-01-01 01:03:00",
#'       "2020-01-01 00:00:00",
#'       "2020-01-01 00:10:00"
#'     ),
#'     tz = "UTC"
#'   ),
#'   y1 = c(1, NA, 3, 4, 5, 6),
#'   y2 = c(NA, 2, 3, 4, 5, 6)
#' )
#'
#' ResolveCloseTimeByID(
#'   data = data,
#'   id = "id",
#'   time = "datetime",
#'   observed = c("y1", "y2"),
#'   min_gap = as.difftime(
#'     5,
#'     units = "mins"
#'   ),
#'   method = "max_complete"
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
ResolveCloseTimeByID <- function(data,
                                 id,
                                 time,
                                 observed,
                                 min_gap,
                                 method = c(
                                   "max_complete",
                                   "first",
                                   "last"
                                 )) {
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
    !is.character(observed) ||
      length(observed) < 1L ||
      any(is.na(observed)) ||
      any(observed == "")
  ) {
    stop(
      "`observed` must be a non-empty character vector.",
      call. = FALSE
    )
  }

  method <- match.arg(method)

  missing_vars <- setdiff(
    x = c(
      id,
      time,
      observed
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

  if (any(is.na(data[[id]]))) {
    stop(
      "`id` must not contain missing values.",
      call. = FALSE
    )
  }

  if (nrow(data) == 0L) {
    rownames(data) <- NULL
    return(data)
  }

  x <- data[[time]]

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

  if (any(is.na(x))) {
    stop(
      "`time` must not contain missing values.",
      call. = FALSE
    )
  }

  if (is_datetime) {
    if (!inherits(min_gap, "difftime")) {
      stop(
        paste(
          "`min_gap` must be a `difftime` object when `time` is",
          "Date or POSIXt."
        ),
        call. = FALSE
      )
    }

    min_gap_value <- as.numeric(
      min_gap,
      units = "secs"
    )

    if (
      length(min_gap_value) != 1L ||
        is.na(min_gap_value) ||
        !is.finite(min_gap_value) ||
        min_gap_value <= 0
    ) {
      stop(
        "`min_gap` must be positive.",
        call. = FALSE
      )
    }
  }

  if (is_numeric_time) {
    if (
      !is.numeric(min_gap) ||
        length(min_gap) != 1L ||
        is.na(min_gap) ||
        !is.finite(min_gap) ||
        min_gap <= 0
    ) {
      stop(
        paste(
          "`min_gap` must be a positive finite numeric scalar when",
          "`time` is numeric."
        ),
        call. = FALSE
      )
    }

    min_gap_value <- min_gap
  }

  temp_order <- ".resolve_close_time_by_id_order"

  while (temp_order %in% names(data)) {
    temp_order <- paste0(
      temp_order,
      "."
    )
  }

  temp_cluster <- ".resolve_close_time_by_id_cluster"

  while (temp_cluster %in% names(data)) {
    temp_cluster <- paste0(
      temp_cluster,
      "."
    )
  }

  data[[temp_order]] <- seq_len(
    nrow(data)
  )

  data <- data[
    order(
      data[[id]],
      data[[time]],
      data[[temp_order]]
    ), ,
    drop = FALSE
  ]

  run <- rle(data[[id]])
  end <- cumsum(run$lengths)
  start <- end - run$lengths + 1L

  keep_all <- logical(
    length = nrow(data)
  )

  for (j in seq_along(start)) {
    index <- seq.int(
      from = start[j],
      to = end[j]
    )

    if (length(index) == 1L) {
      keep_all[index] <- TRUE
      next
    }

    cluster <- integer(
      length = length(index)
    )

    cluster_id <- 1L
    cluster[1L] <- cluster_id

    for (r in 2:length(index)) {
      current_row <- index[r]
      previous_row <- index[r - 1L]

      if (is_datetime) {
        gap <- as.numeric(
          difftime(
            time1 = data[[time]][current_row],
            time2 = data[[time]][previous_row],
            units = "secs"
          )
        )
      } else {
        gap <- data[[time]][current_row] -
          data[[time]][previous_row]
      }

      if (gap >= min_gap_value) {
        cluster_id <- cluster_id + 1L
      }

      cluster[r] <- cluster_id
    }

    cluster_values <- unique(cluster)

    for (cluster_value in cluster_values) {
      cluster_index <- index[
        cluster == cluster_value
      ]

      if (method == "first") {
        keep_index <- cluster_index[1L]
      }

      if (method == "last") {
        keep_index <- cluster_index[
          length(cluster_index)
        ]
      }

      if (method == "max_complete") {
        complete_count <- rowSums(
          !is.na(
            data[
              cluster_index,
              observed,
              drop = FALSE
            ]
          )
        )

        keep_index <- cluster_index[
          which.max(complete_count)
        ]
      }

      keep_all[keep_index] <- TRUE
    }
  }

  out <- data[
    keep_all, ,
    drop = FALSE
  ]

  out[[temp_order]] <- NULL

  rownames(out) <- NULL
  out
}
