#' Replace Missing-Value Codes
#'
#' The function replaces user-specified missing-value codes with `NA` in a
#' data frame. The replacement is applied column by column and preserves the
#' original column classes whenever possible.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @param data Data frame.
#' @param values Vector.
#'   Values to replace with `NA`.
#' @param columns Character vector.
#'   Names of the columns where replacement should be applied. If `NULL`, no
#'   columns are modified.
#'
#' @return Returns a data frame.
#'
#' @examples
#' data <- data.frame(
#'   id = 1:3,
#'   y = c(1, -999, 3),
#'   x = c("a", "-999", "c"),
#'   stringsAsFactors = FALSE
#' )
#' ReplaceMissingCode(
#'   data = data,
#'   values = c(-999, "-999")
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
ReplaceMissingCode <- function(data,
                               values = c(-999, "-999"),
                               columns = names(data)) {
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

  if (is.null(columns)) {
    return(data)
  }

  if (
    !is.character(columns) ||
      any(is.na(columns)) ||
      any(columns == "")
  ) {
    stop(
      "`columns` must be a character vector of column names.",
      call. = FALSE
    )
  }

  columns <- unique(columns)

  missing_columns <- setdiff(
    x = columns,
    y = names(data)
  )

  if (length(missing_columns) > 0L) {
    stop(
      paste0(
        "The following `columns` are not in `data`: ",
        paste(missing_columns, collapse = ", "),
        "."
      ),
      call. = FALSE
    )
  }

  if (is.null(values) || length(values) == 0L) {
    return(data)
  }

  values <- values[
    !is.na(values)
  ]

  if (length(values) == 0L) {
    return(data)
  }

  value_chr <- as.character(values)

  value_num <- suppressWarnings(
    as.numeric(values)
  )
  value_num <- value_num[
    !is.na(value_num)
  ]

  value_log_chr <- tolower(value_chr)
  value_log_ok <- value_log_chr %in% c(
    "true",
    "false",
    "t",
    "f"
  )
  if (any(value_log_ok)) {
    value_log <- value_log_chr[value_log_ok] %in% c(
      "true",
      "t"
    )
  } else {
    value_log <- logical(0)
  }

  for (column in columns) {
    x <- data[[column]]

    if (is.factor(x)) {
      key <- as.character(x)
      replace <- !is.na(key) & key %in% value_chr
      x[replace] <- NA
      data[[column]] <- x
    } else if (is.character(x)) {
      replace <- !is.na(x) & x %in% value_chr
      data[[column]][replace] <- NA_character_
    } else if (is.numeric(x)) {
      replace <- !is.na(x) & x %in% value_num
      data[[column]][replace] <- NA
    } else if (is.logical(x)) {
      replace <- !is.na(x) & x %in% value_log
      data[[column]][replace] <- NA
    } else if (inherits(x, "Date") || inherits(x, "POSIXt")) {
      key <- as.character(x)
      replace <- !is.na(key) & key %in% value_chr
      x[replace] <- NA
      data[[column]] <- x
    } else {
      key <- as.character(x)
      replace <- !is.na(key) & key %in% value_chr
      x[replace] <- NA
      data[[column]] <- x
    }
  }

  data
}
