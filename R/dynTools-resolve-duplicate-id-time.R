#' Resolve Duplicate ID-Time Rows
#'
#' The function resolves exact duplicate `id`-`time` rows using a simple
#' deterministic rule. This is useful before inserting missing rows on a time
#' grid because grid-completion functions generally require unique
#' `id`-`time` combinations.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param method Character string.
#'   Rule used to choose one row from each duplicated `id`-`time` group.
#'   If `method = "first"`, keep the first row after sorting by `id` and
#'   `time`. If `method = "last"`, keep the last row after sorting by `id`
#'   and `time`. If `method = "max_complete"`, keep the row with the largest
#'   number of non-missing values in `observed`.
#' @param order_by Character vector.
#'   Optional columns used to break ties after the main `method` rule.
#' @param decreasing Logical.
#'   If `TRUE`, sort `order_by` columns in decreasing order.
#'
#' @return Returns a data frame with unique `id`-`time` rows.
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 1),
#'   time = c(0, 0, 1),
#'   y1 = c(NA, 1, 2),
#'   y2 = c(NA, 1, 3)
#' )
#' data
#'
#' ResolveDuplicateIDTime(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = c("y1", "y2"),
#'   method = "max_complete"
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
ResolveDuplicateIDTime <- function(data,
                                   id,
                                   time,
                                   observed = NULL,
                                   covariates = NULL,
                                   method = c(
                                     "first",
                                     "last",
                                     "max_complete"
                                   ),
                                   order_by = NULL,
                                   decreasing = FALSE) {
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

  if (!is.null(observed)) {
    if (
      !is.character(observed) ||
        any(is.na(observed)) ||
        any(observed == "")
    ) {
      stop(
        "`observed` must be a character vector of column names.",
        call. = FALSE
      )
    }

    observed <- unique(observed)
  }

  if (!is.null(covariates)) {
    if (
      !is.character(covariates) ||
        any(is.na(covariates)) ||
        any(covariates == "")
    ) {
      stop(
        "`covariates` must be a character vector of column names.",
        call. = FALSE
      )
    }

    covariates <- unique(covariates)
  }

  if (!is.null(order_by)) {
    if (
      !is.character(order_by) ||
        any(is.na(order_by)) ||
        any(order_by == "")
    ) {
      stop(
        "`order_by` must be a character vector of column names.",
        call. = FALSE
      )
    }

    order_by <- unique(order_by)
  }

  method <- match.arg(method)

  if (
    !is.logical(decreasing) ||
      length(decreasing) != 1L ||
      is.na(decreasing)
  ) {
    stop(
      "`decreasing` must be `TRUE` or `FALSE`.",
      call. = FALSE
    )
  }

  vars <- unique(
    c(
      id,
      time,
      observed,
      covariates,
      order_by
    )
  )

  missing_vars <- setdiff(
    x = vars,
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

  if (nrow(data) == 0L) {
    rownames(data) <- NULL
    return(data)
  }

  if (any(is.na(data[[id]]))) {
    stop(
      "`id` must not contain missing values.",
      call. = FALSE
    )
  }

  if (any(is.na(data[[time]]))) {
    stop(
      "`time` must not contain missing values.",
      call. = FALSE
    )
  }

  original_index <- seq_len(
    nrow(data)
  )

  score <- NULL

  if (method == "max_complete") {
    complete_vars <- observed

    if (is.null(complete_vars)) {
      complete_vars <- setdiff(
        x = names(data),
        y = c(
          id,
          time
        )
      )
    }

    if (length(complete_vars) == 0L) {
      score <- rep(
        x = 0L,
        times = nrow(data)
      )
    } else {
      score <- rowSums(
        x = !is.na(
          data[
            ,
            complete_vars,
            drop = FALSE
          ]
        )
      )
    }
  }

  order_args <- list(
    data[[id]],
    data[[time]]
  )

  if (method == "max_complete") {
    order_args <- c(
      order_args,
      list(-score)
    )
  }

  if (!is.null(order_by)) {
    for (var in order_by) {
      x <- data[[var]]

      if (decreasing) {
        if (is.numeric(x) || is.logical(x)) {
          x <- -as.numeric(x)
        } else if (inherits(x, "Date") || inherits(x, "POSIXt")) {
          x <- -as.numeric(x)
        } else {
          x <- -rank(
            x = x,
            ties.method = "first",
            na.last = "keep"
          )
        }
      }

      order_args <- c(
        order_args,
        list(x)
      )
    }
  }

  if (method == "last") {
    order_args <- c(
      order_args,
      list(-original_index)
    )
  } else {
    order_args <- c(
      order_args,
      list(original_index)
    )
  }

  ord <- do.call(
    what = "order",
    args = c(
      order_args,
      list(
        na.last = TRUE
      )
    )
  )

  data <- data[
    ord, ,
    drop = FALSE
  ]

  key <- paste(
    data[[id]],
    data[[time]],
    sep = "\r"
  )

  data <- data[
    !duplicated(key), ,
    drop = FALSE
  ]

  rownames(data) <- NULL
  data
}
