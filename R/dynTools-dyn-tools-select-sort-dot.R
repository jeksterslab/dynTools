.DynToolsSelectSort <- function(data,
                                id,
                                time,
                                observed,
                                covariates = NULL) {
  vars <- unique(
    c(
      id,
      time,
      observed,
      covariates
    )
  )

  data <- data[
    ,
    vars,
    drop = FALSE
  ]

  data <- data[
    order(
      data[[id]],
      data[[time]]
    ), ,
    drop = FALSE
  ]

  rownames(data) <- NULL
  data
}
