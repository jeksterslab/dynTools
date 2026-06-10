#' Plot Observed Variables by ID
#'
#' The function creates one time-series plot for each observed variable.
#' Within each plot, trajectories are overlaid by ID.
#'
#' @author Ivan Jacob Agaloos Pesigan
#'
#' @inheritParams SubsetByID
#' @param ids Optional vector.
#'   ID values to plot.
#'   If `NULL`, all available IDs are plotted.
#' @param times Optional vector of time values.
#'   If `NULL`, all available time points are plotted.
#'   If supplied, the range of `times` is used to subset the data.
#'   For example, `times = c(0, 9)` plots all rows with time values
#'   from 0 to 9, inclusive.
#' @param type Character string.
#'   Plot type passed to [graphics::lines()].
#'   Default is `"b"`.
#' @param pch Optional vector of plotting characters.
#'   If `NULL`, plotting characters are generated automatically by ID.
#'   Recycled to match the number of plotted IDs.
#' @param lty Optional vector of line types.
#'   If `NULL`, line types are generated automatically by ID.
#'   Recycled to match the number of plotted IDs.
#' @param col Optional vector of colors.
#'   If `NULL`, colors are generated automatically by ID.
#'   Recycled to match the number of plotted IDs.
#' @param xlab Optional character string.
#'   Label for the x-axis.
#'   If `NULL`, the name of the time variable is used.
#' @param ylab Optional character string.
#'   Label for the y-axis.
#'   If `NULL`, the observed variable name is used.
#' @param main Optional character string.
#'   Plot title prefix.
#'   If `NULL`, the observed variable name is used.
#' @param xlim Optional vector of length 2.
#'   Limits for the x-axis.
#' @param ylim Optional numeric vector of length 2.
#'   Limits for the y-axis.
#'   If `NULL`, limits are computed separately for each observed variable.
#' @param legend Logical.
#'   If `TRUE`, add a legend identifying IDs.
#' @param ask Logical.
#'   If `TRUE`, ask before drawing the next observed-variable plot.
#'   The default is `TRUE` in interactive sessions when plotting more than
#'   one observed variable.
#' @param ... Additional arguments passed to [graphics::lines()].
#'
#' @return Invisibly returns the IDs that were plotted.
#'
#' @examples
#' data <- data.frame(
#'   id = rep(1:4, each = 5),
#'   time = rep(1:5, times = 4),
#'   y1 = c(
#'     1, 2, 3, 4, 5,
#'     2, 3, 4, 5, 6,
#'     3, 4, 5, 6, 7,
#'     4, 5, 6, 7, 8
#'   ),
#'   y2 = c(
#'     5, 4, 3, 2, 1,
#'     6, 5, 4, 3, 2,
#'     7, 6, 5, 4, 3,
#'     8, 7, 6, 5, 4
#'   ),
#'   y3 = c(
#'     1, 1, 2, 2, 3,
#'     2, 2, 3, 3, 4,
#'     3, 3, 4, 4, 5,
#'     4, 4, 5, 5, 6
#'   )
#' )
#' data
#'
#' PlotByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = paste0("y", 1:3),
#'   ask = FALSE
#' )
#'
#' PlotByID(
#'   data = data,
#'   id = "id",
#'   time = "time",
#'   observed = paste0("y", 1:3),
#'   ids = 1:3,
#'   times = c(1, 3),
#'   legend = TRUE,
#'   ask = FALSE
#' )
#'
#' @family Dynamic Modeling Utility Functions
#' @keywords dynTools plot
#' @export
PlotByID <- function(data,
                     id,
                     time,
                     observed,
                     ids = NULL,
                     times = NULL,
                     type = "b",
                     pch = NULL,
                     lty = NULL,
                     col = NULL,
                     xlab = NULL,
                     ylab = NULL,
                     main = NULL,
                     xlim = NULL,
                     ylim = NULL,
                     legend = FALSE,
                     ask = NULL,
                     ...) {
  if (!is.data.frame(data)) {
    stop(
      "`data` must be a data frame.",
      call. = FALSE
    )
  }

  if (!is.character(id) || length(id) != 1) {
    stop(
      "`id` must be a character string.",
      call. = FALSE
    )
  }

  if (!is.character(time) || length(time) != 1) {
    stop(
      "`time` must be a character string.",
      call. = FALSE
    )
  }

  if (!is.character(observed) || length(observed) < 1) {
    stop(
      "`observed` must be a character vector.",
      call. = FALSE
    )
  }

  vars <- c(id, time, observed)

  missing_vars <- setdiff(
    x = vars,
    y = names(data)
  )

  if (length(missing_vars) > 0) {
    stop(
      "These variables are not in `data`: ",
      paste(missing_vars, collapse = ", "),
      call. = FALSE
    )
  }

  is_num <- vapply(
    X = data[observed],
    FUN = is.numeric,
    FUN.VALUE = logical(1)
  )

  if (!all(is_num)) {
    stop(
      "All `observed` variables must be numeric.",
      call. = FALSE
    )
  }

  if (all(is.na(data[[time]]))) {
    stop(
      "`time` contains only missing values.",
      call. = FALSE
    )
  }

  if (!is.null(ids)) {
    data <- data[
      data[[id]] %in% ids, ,
      drop = FALSE
    ]
  }

  if (!is.null(times)) {
    if (length(times) < 1 || all(is.na(times))) {
      stop(
        "`times` must contain at least one non-missing value.",
        call. = FALSE
      )
    }

    times <- range(
      times,
      na.rm = TRUE
    )

    keep_time <- !is.na(data[[time]]) &
      data[[time]] >= times[1] &
      data[[time]] <= times[2]

    data <- data[
      keep_time, ,
      drop = FALSE
    ]
  }

  if (nrow(data) == 0) {
    stop(
      "No rows remain after applying `ids` and `times` filters.",
      call. = FALSE
    )
  }

  ids_plot <- unique(data[[id]])
  ids_plot <- ids_plot[!is.na(ids_plot)]

  if (length(ids_plot) == 0) {
    stop(
      "No matching IDs found.",
      call. = FALSE
    )
  }

  n_ids <- length(ids_plot)

  if (is.null(col)) {
    colfunc <- grDevices::colorRampPalette(
      c(
        "red",
        "yellow",
        "springgreen",
        "royalblue"
      )
    )
    col <- colfunc(n_ids)
  }

  if (is.null(pch)) {
    pch <- seq_len(n_ids)
    pch <- ((pch - 1) %% 25) + 1
  }

  if (is.null(lty)) {
    lty <- seq_len(n_ids)
    lty <- ((lty - 1) %% 6) + 1
  }

  if (length(col) < 1) {
    stop(
      "`col` must contain at least one color.",
      call. = FALSE
    )
  }

  if (length(pch) < 1) {
    stop(
      "`pch` must contain at least one plotting character.",
      call. = FALSE
    )
  }

  if (length(lty) < 1) {
    stop(
      "`lty` must contain at least one line type.",
      call. = FALSE
    )
  }

  if (!is.logical(legend) || length(legend) != 1 || is.na(legend)) {
    stop(
      "`legend` must be a single logical value.",
      call. = FALSE
    )
  }

  col <- rep(
    x = col,
    length.out = n_ids
  )

  pch <- rep(
    x = pch,
    length.out = n_ids
  )

  lty <- rep(
    x = lty,
    length.out = n_ids
  )

  if (is.null(xlim)) {
    xlim <- range(
      data[[time]],
      na.rm = TRUE
    )
  }

  if (is.null(xlab)) {
    xlab <- time
  }

  if (is.null(ask)) {
    ask <- interactive() && length(observed) > 1
  }

  if (!is.logical(ask) || length(ask) != 1 || is.na(ask)) {
    stop(
      "`ask` must be a single logical value.",
      call. = FALSE
    )
  }

  old_ask <- graphics::par("ask")
  on.exit(
    graphics::par(ask = old_ask),
    add = TRUE
  )

  graphics::par(ask = ask)

  for (i in seq_along(observed)) {
    y_i <- observed[i]

    if (all(is.na(data[[y_i]]))) {
      warning(
        "Skipping `",
        y_i,
        "` because it contains only missing values.",
        call. = FALSE
      )
      next
    }

    ylim_i <- if (is.null(ylim)) {
      range(
        data[[y_i]],
        na.rm = TRUE
      )
    } else {
      ylim
    }

    ylab_i <- if (is.null(ylab)) {
      y_i
    } else {
      ylab
    }

    main_i <- if (is.null(main)) {
      y_i
    } else {
      paste0(main, " | ", y_i)
    }

    graphics::plot(
      x = data[[time]],
      y = data[[y_i]],
      xlim = xlim,
      ylim = ylim_i,
      type = "n",
      xlab = xlab,
      ylab = ylab_i,
      main = main_i
    )

    for (j in seq_along(ids_plot)) {
      keep_id <- !is.na(data[[id]]) & data[[id]] == ids_plot[j]

      subset_data <- data[
        keep_id, ,
        drop = FALSE
      ]

      subset_data <- subset_data[
        order(subset_data[[time]]), ,
        drop = FALSE
      ]

      graphics::lines(
        x = subset_data[[time]],
        y = subset_data[[y_i]],
        type = type,
        col = col[j],
        pch = pch[j],
        lty = lty[j],
        ...
      )
    }

    if (legend) {
      graphics::legend(
        x = "topright",
        legend = ids_plot,
        col = col,
        pch = pch,
        lty = lty,
        bty = "n",
        title = id
      )
    }
  }

  invisible(ids_plot)
}
