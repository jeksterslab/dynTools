#' Combine Data Sets by ID and Time
#'
#' The function appends observed variables from one data set to another data
#' set using exact `id`-`time` matches. Rows in `data` define the output
#' `id`-`time` structure. If an `id`-`time` row in `data` is not present in
#' `append_data`, missing values are inserted for the appended observed
#' variables.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param append_data Data frame.
#' A data frame object containing the `id` and `time` columns and the
#' observed variables to append to `data`.
#'
#' @return Returns a data frame.
#'
#' @examples
#' data <- data.frame(
#'   id = c(1, 1, 1, 2, 2, 2),
#'   time = c(1, 2, 3, 1, 2, 3),
#'   cov = c(10, 10, 10, 20, 20, 20)
#' )
#'
#' append_data <- data.frame(
#'   id = c(1, 1, 2),
#'   time = c(1, 3, 2),
#'   y1 = c(11, 13, 22),
#'   y2 = c(101, 103, 202)
#' )
#'
#' CombineByIDTime(
#'   data = data,
#'   append_data = append_data,
#'   id = "id",
#'   time = "time",
#'   observed = c("y1", "y2"),
#'   covariates = "cov"
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
CombineByIDTime <- function(data,
                            append_data,
                            id,
                            time,
                            observed,
                            covariates = NULL) {
  if (!is.data.frame(data)) {
    stop(
      "`data` must be a data frame.",
      call. = FALSE
    )
  }
  if (!is.data.frame(append_data)) {
    stop(
      "`append_data` must be a data frame.",
      call. = FALSE
    )
  }
  if (anyDuplicated(names(data))) {
    dup <- unique(
      names(data)[duplicated(names(data))]
    )
    stop(
      paste0(
        "`data` must have unique column names. Duplicated: ",
        paste(dup, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }
  if (anyDuplicated(names(append_data))) {
    dup <- unique(
      names(append_data)[duplicated(names(append_data))]
    )
    stop(
      paste0(
        "`append_data` must have unique column names. Duplicated: ",
        paste(dup, collapse = ", "),
        "."
      ),
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

  observed <- unique(observed)
  covariates <- unique(covariates)

  vars <- c(
    id,
    time,
    observed,
    covariates
  )
  if (anyDuplicated(vars)) {
    dup <- unique(
      vars[duplicated(vars)]
    )
    stop(
      paste0(
        "`id`, `time`, `observed`, and `covariates` must identify ",
        "unique variables. Duplicated: ",
        paste(dup, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  data_vars <- unique(
    c(
      id,
      time,
      covariates
    )
  )
  missing_data <- setdiff(
    x = data_vars,
    y = names(data)
  )
  if (length(missing_data) > 0L) {
    stop(
      paste0(
        "The following variables are missing from `data`: ",
        paste(missing_data, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  append_vars <- unique(
    c(
      id,
      time,
      observed
    )
  )
  missing_append <- setdiff(
    x = append_vars,
    y = names(append_data)
  )
  if (length(missing_append) > 0L) {
    stop(
      paste0(
        "The following variables are missing from `append_data`: ",
        paste(missing_append, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  if (any(is.na(data[[id]]))) {
    stop(
      "`id` must not contain missing values in `data`.",
      call. = FALSE
    )
  }
  if (any(is.na(data[[time]]))) {
    stop(
      "`time` must not contain missing values in `data`.",
      call. = FALSE
    )
  }
  if (any(is.na(append_data[[id]]))) {
    stop(
      "`id` must not contain missing values in `append_data`.",
      call. = FALSE
    )
  }
  if (any(is.na(append_data[[time]]))) {
    stop(
      "`time` must not contain missing values in `append_data`.",
      call. = FALSE
    )
  }

  data <- .DynToolsSelectSort(
    data = data,
    id = id,
    time = time,
    observed = character(0),
    covariates = covariates
  )

  append_data <- .DynToolsSelectSort(
    data = append_data,
    id = id,
    time = time,
    observed = observed,
    covariates = NULL
  )

  key_data <- paste(
    data[[id]],
    data[[time]],
    sep = "\r"
  )
  key_append <- paste(
    append_data[[id]],
    append_data[[time]],
    sep = "\r"
  )

  if (anyDuplicated(key_data)) {
    stop(
      "`data` must have unique `id`-`time` combinations.",
      call. = FALSE
    )
  }
  if (anyDuplicated(key_append)) {
    stop(
      "`append_data` must have unique `id`-`time` combinations.",
      call. = FALSE
    )
  }

  pos <- match(
    x = key_data,
    table = key_append
  )
  matched <- !is.na(pos)

  out <- data

  for (j in seq_along(observed)) {
    var <- observed[j]
    out[[var]] <- append_data[[var]][
      rep.int(
        x = NA_integer_,
        times = nrow(out)
      )
    ]
    out[[var]][matched] <- append_data[[var]][
      pos[matched]
    ]
  }

  rownames(out) <- NULL
  out
}
