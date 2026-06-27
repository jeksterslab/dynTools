.DynToolsSafeName <- function(x) {
  gsub(
    pattern = "[^[:alnum:]_]+",
    replacement = "_",
    x = x
  )
}
