.DynToolsSafeCut <- function(x) {
  out <- format(
    x = x,
    trim = TRUE,
    scientific = FALSE
  )

  out <- gsub(
    pattern = "\\.",
    replacement = "_",
    x = out
  )

  out
}
