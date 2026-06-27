#' Trim Leading Rows With Too Few Observed Values by ID
#'
#' The function removes leading rows within each ID until the first retained row
#' has at least `min_nonmissing` non-missing observed variables. This is useful
#' before creating an elapsed-time variable when leading records contain no
#' usable measurements. Unlike [DeleteInitialNA()], the default does not require
#' the first retained row to be complete on all selected variables.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param min_nonmissing Positive integer.
#'   Minimum number of non-missing observed variables required in the first
#'   retained row for each ID.
#'
#' @return Returns a data frame.
#'
#' @examples
#' data <- data.frame(
#'   id = rep(1:2, each = 4),
#'   time = rep(1:4, times = 2),
#'   y1 = c(NA, 1, 2, 3, NA, NA, 1, 2),
#'   y2 = c(NA, NA, 2, 3, NA, 1, 1, 2)
#' )
#'
#' TrimInitialRowsByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = c("y1", "y2"),
#'   min_nonmissing = 1
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
TrimInitialRowsByID <- function(data,
                                id,
                                time,
                                observed,
                                covariates = NULL,
                                min_nonmissing = 1L) {
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

  data <- .DynToolsSelectSort(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates
  )

  if (nrow(data) == 0L) {
    return(data)
  }

  run <- rle(data[[id]])
  end <- cumsum(run$lengths)
  start <- end - run$lengths + 1L

  keep <- vector(
    mode = "list",
    length = length(start)
  )

  nonmissing <- rowSums(
    !is.na(
      data[
        ,
        observed,
        drop = FALSE
      ]
    )
  )

  ok <- nonmissing >= min_nonmissing

  for (j in seq_along(start)) {
    index <- seq.int(
      from = start[j],
      to = end[j]
    )

    first <- match(
      x = TRUE,
      table = ok[index]
    )

    if (is.na(first)) {
      keep[[j]] <- integer(0)
    } else {
      keep[[j]] <- index[
        seq.int(
          from = first,
          to = length(index)
        )
      ]
    }
  }

  keep <- unlist(
    x = keep,
    use.names = FALSE
  )

  out <- data[
    keep, ,
    drop = FALSE
  ]

  rownames(out) <- NULL
  out
}
