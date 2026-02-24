#' Create Figure Specification
#'
#' Defines a backend-agnostic figure specification.
#'
#' @param data A data.frame.
#' @param x Column name for x-axis.
#' @param y Column name for y-axis.
#' @param xlab Optional x-axis label.
#' @param ylab Optional y-axis label.
#'
#' @return An object of class `fig_spec`.
#' @export
fig_spec <- function(data, x, y,
                     xlab = NULL,
                     ylab = NULL) {

  structure(
    list(
      data = data,
      x = x,
      y = y,
      xlab = xlab %||% x,
      ylab = ylab %||% y
    ),
    class = "fig_spec"
  )
}
