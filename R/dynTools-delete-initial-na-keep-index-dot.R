.DeleteInitialNAKeepIndex <- function(j,
                                      start,
                                      end,
                                      ok) {
  index <- seq.int(
    from = start[j],
    to = end[j]
  )

  first <- match(
    x = TRUE,
    table = ok[index]
  )

  if (is.na(first)) {
    integer(0)
  } else {
    index[
      seq.int(
        from = first,
        to = length(index)
      )
    ]
  }
}
