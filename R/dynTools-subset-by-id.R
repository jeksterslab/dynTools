#' Subset Data Set by ID
#'
#' The function creates a list of data frames for each ID.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @return Returns a list by ID numbers.
#'
#' @param data Data frame.
#'   A data frame object of data for potentially
#'   multiple subjects that contain
#'   a column of subject ID numbers
#'   (i.e., an ID variable),
#'   a column indicating subject-specific measurement occasions
#'   (i.e., a TIME variable),
#'   at least one column of observed values.
#' @param observed Character vector.
#'   A vector of character strings
#'   of the names of the observed variables in the data.
#' @param covariates Character vector.
#'   A vector of character strings
#'   of the names of the covariates in the data.
#' @param id Character string.
#'   A character string of the name of the ID variable in the data.
#' @param time Character string.
#'   A character string of the name of the TIME variable in the data.
#'
#' @examples
#' data <- data.frame(
#'   id = rep(1:3, each = 4),
#'   time = rep(1:4, times = 3),
#'   y1 = c(
#'     1, 2, 3, 4,
#'     10, 11, 12, 13,
#'     20, 21, 22, 23
#'   ),
#'   y2 = c(
#'     4, 3, 2, 1,
#'     13, 12, 11, 10,
#'     23, 22, 21, 20
#'   )
#' )
#' data
#'
#' SubsetByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = c("y1", "y2")
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools data
#' @export
SubsetByID <- function(data,
                       id,
                       time,
                       observed,
                       covariates = NULL) {
  stopifnot(
    is.data.frame(data)
  )

  data <- .DynToolsSelectSort(
    data = data,
    id = id,
    time = time,
    observed = observed,
    covariates = covariates
  )

  ids <- unique(data[[id]])

  if (nrow(data) == 0L) {
    output <- list()
  } else {
    run <- rle(data[[id]])
    end <- cumsum(run$lengths)
    start <- end - run$lengths + 1L

    output <- vector(
      mode = "list",
      length = length(start)
    )

    for (j in seq_along(start)) {
      output[[j]] <- data[
        seq.int(
          from = start[j],
          to = end[j]
        ), ,
        drop = FALSE
      ]
      rownames(output[[j]]) <- NULL
    }

    names(output) <- as.character(ids)
  }

  output
}
