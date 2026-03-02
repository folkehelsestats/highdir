# figure-spec.R — Backend-agnostic figure specification object
#
# A fig_spec carries everything needed to render a figure: the data, the
# aesthetic mapping (x, y, group, colour), axis labels, title, subtitle,
# caption, and chart-level options such as ylim, yint, flip, etc.
#
# By putting all configuration into the spec rather than scattering it across
# make_fig() arguments, we make it easy to serialise, inspect, and pass
# specifications around without touching the rendering layer.

#' Create a Figure Specification
#'
#' Defines a backend-agnostic description of a figure. Pass the returned
#' object to [make_fig()] to render it with either `"highcharter"` or
#' `"ggplot2"`.
#'
#' @param data A `data.frame` (or `data.table`) containing all referenced
#'   columns.
#' @param x Character. Column name for the x-axis variable.
#' @param y Character. Column name for the y-axis variable (typically a
#'   percentage or count).
#' @param group Character or `NULL`. Column name used to split the data into
#'   multiple series / groups.
#' @param n Character or `NULL`. Column name of a raw count variable shown
#'   in highcharter tooltips alongside the y value. Ignored for ggplot2.
#' @param colour Character or `NULL`. Column name mapped to the colour
#'   aesthetic (ggplot2 only; highcharter uses `group` for colouring).
#' @param xlab Character or `NULL`. X-axis label. Defaults to `x` when
#'   `NULL`.
#' @param ylab Character or `NULL`. Y-axis label. Defaults to `y` when
#'   `NULL`.
#' @param title Character or `NULL`. Chart title.
#' @param subtitle Character or `NULL`. Chart subtitle. Defaults to
#'   `"Kilde: Navn av kilder"` in the highcharter engine when `NULL`.
#' @param caption Character or `NULL`. Caption text shown below the chart
#'   (highcharter only).
#' @param ylim Numeric vector of length 2 or `NULL`. Fixed y-axis limits,
#'   e.g. `c(0, 100)`. `NULL` lets the backend determine limits
#'   automatically.
#' @param yint Numeric. Y-axis tick interval. Default `10`.
#' @param flip Logical. Invert axes (horizontal bars). Default `FALSE`.
#'
#' @return An object of S3 class `fig_spec`.
#'
#' @examples
#' df <- data.frame(
#'   age   = rep(c("18-24", "25-34", "35-44"), each = 2),
#'   sex   = rep(c("Male", "Female"), 3),
#'   pct   = c(42, 38, 55, 61, 48, 52),
#'   n     = c(120, 115, 200, 210, 180, 175)
#' )
#'
#' spec <- fig_spec(
#'   data     = df,
#'   x        = "age",
#'   y        = "pct",
#'   group    = "sex",
#'   n        = "n",
#'   title    = "Health survey results",
#'   subtitle = "Source: Example data"
#' )
#' spec
#'
#' @export
fig_spec <- function(data,
                     x,
                     y,
                     group    = NULL,
                     n        = NULL,
                     colour   = NULL,
                     xlab     = NULL,
                     ylab     = NULL,
                     title    = NULL,
                     subtitle = NULL,
                     caption  = NULL,
                     ylim     = NULL,
                     yint     = 10,
                     flip     = FALSE) {

  # ---- Validate inputs -------------------------------------------------------
  if (!is.data.frame(data))
    stop("`data` must be a data.frame", call. = FALSE)

  check_columns(data, c(x, y, group, n, colour))
  check_ylim(ylim)

  if (!is.numeric(yint) || length(yint) != 1 || yint <= 0)
    stop("`yint` must be a single positive number", call. = FALSE)

  # ---- Build spec object -----------------------------------------------------
  structure(
    list(
      data     = data,
      x        = x,
      y        = y,
      group    = group,
      n        = n,
      colour   = colour,
      xlab     = xlab     %||% x,
      ylab     = ylab     %||% y,
      title    = title,
      subtitle = subtitle,
      caption  = caption,
      ylim     = ylim,
      yint     = yint,
      flip     = flip
    ),
    class = "fig_spec"
  )
}

# ---------------------------------------------------------------------------
# S3 methods for fig_spec
# ---------------------------------------------------------------------------

#' Print a fig_spec Object
#'
#' @param x A `fig_spec` object.
#' @param ... Ignored.
#' @return `x`, invisibly.
#' @export
print.fig_spec <- function(x, ...) {
  cat("<fig_spec>\n")
  cat("  x        :", x$x,     "\n")
  cat("  y        :", x$y,     "\n")
  if (!is.null(x$group))    cat("  group    :", x$group,    "\n")
  if (!is.null(x$n))        cat("  n        :", x$n,        "\n")
  if (!is.null(x$colour))   cat("  colour   :", x$colour,   "\n")
  if (!is.null(x$title))    cat("  title    :", x$title,    "\n")
  if (!is.null(x$subtitle)) cat("  subtitle :", x$subtitle, "\n")
  if (!is.null(x$caption))  cat("  caption  :", x$caption,  "\n")
  if (!is.null(x$ylim))     cat("  ylim     :", x$ylim,     "\n")
  cat("  yint     :", x$yint,  "\n")
  cat("  flip     :", x$flip,  "\n")
  cat("  rows     :", nrow(x$data), "\n")
  invisible(x)
}

#' Convert fig_spec to a List
#'
#' @param x A `fig_spec` object.
#' @param ... Ignored.
#' @return A plain list (without the `data` slot, to keep output readable).
#' @export
as.list.fig_spec <- function(x, ...) {
  out <- unclass(x)
  out$data <- paste0("<data.frame [", nrow(x$data), " x ", ncol(x$data), "]>")
  out
}
