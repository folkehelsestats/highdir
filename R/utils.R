#' NULL Coalescing Operator
#'
#' Returns left-hand side if not NULL, otherwise right-hand side.
#'
#' @param a First value
#' @param b Fallback value
#' @return One of the inputs
#' @export
`%||%` <- function(a, b) {
  if (is.null(a)) b else a
}
