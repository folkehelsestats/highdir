# R/figure-spec.R ── Figure specification objects
#
# Two complementary constructors are provided:
#
#   hd_spec()  — *what* the data means  (x, y, group, n, axis labels)
#   fig_opts()  — *how* it should look   (title, ylim, flip, colours, theme)
#
# Keeping them separate means:
#   * The same hd_spec can be rendered with different opts (e.g. EN vs NO
#     titles) without repeating data-mapping code.
#   * fig_opts objects are reusable across multiple specs.
#   * Validation errors are localised to the object they belong to.

# ════════════════════════════════════════════════════════════════════════════
# hd_spec ── data mapping
# ════════════════════════════════════════════════════════════════════════════

#' Create a Figure Data Specification
#'
#' Defines the **data mapping** for a figure — which columns map to x, y,
#' group, and count — independently of any visual presentation choices.
#' Pass the result to [hd_make()] together with an optional [fig_opts()]
#' object.
#'
#' @param data   A `data.frame` containing all referenced columns.
#' @param x      Character. Column name for the x-axis variable.
#' @param y      Character. Column name for the y-axis variable (typically
#'   a percentage or count).
#' @param group  Character or `NULL`. Column used to split data into multiple
#'   series.
#' @param n      Character or `NULL`. Column of raw counts shown in
#'   highcharter tooltips alongside the y value.  Ignored by ggplot2.
#' @param colour Character or `NULL`. ggplot2 colour aesthetic column.
#'   Defaults to `group` when `NULL` and `group` is set.
#' @param xlab   Character or `NULL`. X-axis label.  Defaults to `x`.
#' @param ylab   Character or `NULL`. Y-axis label.  Defaults to `y`.
#'
#' @return An S3 object of class `"hd_spec"`.
#'
#' @seealso [fig_opts()], [hd_make()]
#'
#' @examples
#' df <- data.frame(
#'   age = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
#'   sex = rep(c("Male", "Female"), 4),
#'   pct = c(42, 38, 55, 61, 48, 52, 60, 57),
#'   n   = c(120, 115, 200, 210, 180, 175, 160, 155)
#' )
#'
#' spec <- hd_spec(df, x = "age", y = "pct", group = "sex", n = "n",
#'                  ylab = "Percentage (%)")
#' spec
#'
#' @export
hd_spec <- function(data,
                     x,
                     y,
                     group  = NULL,
                     n      = NULL,
                     colour = NULL,
                     xlab   = NULL,
                     ylab   = NULL) {

  if (!is.data.frame(data))
    stop("`data` must be a data.frame.", call. = FALSE)

  check_columns(data, c(x, y, group, n, colour))

  structure(
    list(
      data   = as.data.frame(data),   # strip tibble/data.table subclasses
      x      = x,
      y      = y,
      group  = group,
      n      = n,
      colour = colour,
      xlab   = xlab %||% x,
      ylab   = ylab %||% y
    ),
    class = "hd_spec"
  )
}

# ── S3 methods ───────────────────────────────────────────────────────────────

#' @export
print.hd_spec <- function(x, ...) {
  cat("<hd_spec>\n")
  cat("  x      :", x$x,    "\n")
  cat("  y      :", x$y,    "\n")
  cat("  xlab   :", x$xlab, "\n")
  cat("  ylab   :", x$ylab, "\n")
  if (!is.null(x$group))  cat("  group  :", x$group,  "\n")
  if (!is.null(x$n))      cat("  n      :", x$n,      "\n")
  if (!is.null(x$colour)) cat("  colour :", x$colour, "\n")
  cat("  rows   :", nrow(x$data), "\n")
  invisible(x)
}

#' @export
as.list.hd_spec <- function(x, ...) {
  out      <- unclass(x)
  out$data <- sprintf("<data.frame [%d x %d]>", nrow(x$data), ncol(x$data))
  out
}

# ════════════════════════════════════════════════════════════════════════════
# fig_opts ── presentation options
# ════════════════════════════════════════════════════════════════════════════

#' Create Figure Presentation Options
#'
#' Defines the **visual presentation** of a figure independently from the data
#' mapping.  Pass the result as the `opts` argument of [hd_make()], or omit
#' it to accept all defaults.
#'
#' Because opts are separate from [hd_spec()], the same data mapping can
#' be rendered with multiple styles without repetition:
#'
#' ```r
#' spec    <- hd_spec(df, "age", "pct", group = "sex")
#' opts_en <- fig_opts(title = "Health survey",    subtitle = "All ages")
#' opts_no <- fig_opts(title = "Helseundersøkelse", subtitle = "Alle aldre")
#'
#' hd_make(spec, "column", opts_en)
#' hd_make(spec, "column", opts_no)
#' ```
#'
#' @param title    Character or `NULL`. Chart title.
#' @param subtitle Character or `NULL`. Subtitle.  Highcharter default:
#'   `"Kilde: Navn av kilder"`.
#' @param caption  Character or `NULL`. Caption text (highcharter only).
#' @param ylim     Numeric vector of length 2 or `NULL`. Fixed y-axis limits,
#'   e.g. `c(0, 100)`.
#' @param yint     Positive numeric. Y-axis tick interval.  Default `10`.
#' @param flip     Logical. Invert axes (horizontal bars).  Default `FALSE`.
#' @param colors   Character vector, palette name string, or `NULL`.
#'   Per-figure colour override; takes precedence over [hd_set_theme()].
#' @param hc_theme Character or `NULL`. Per-figure highcharter theme name;
#'   takes precedence over [hd_set_theme()].
#'
#' @return An S3 object of class `"fig_opts"`.
#'
#' @seealso [hd_spec()], [hd_make()], [hd_set_theme()]
#'
#' @examples
#' opts <- fig_opts(
#'   title    = "Health survey results",
#'   subtitle = "Source: FHI 2024",
#'   caption  = "Tall om helse",
#'   ylim     = c(0, 100),
#'   yint     = 20,
#'   colors   = c("#025169", "#7C145C")
#' )
#' opts
#'
#' @export
fig_opts <- function(title    = NULL,
                     subtitle = NULL,
                     caption  = NULL,
                     ylim     = NULL,
                     yint     = 10,
                     flip     = FALSE,
                     colors   = NULL,
                     hc_theme = NULL) {

  check_ylim(ylim)
  if (!is.numeric(yint) || length(yint) != 1 || yint <= 0)
    stop("`yint` must be a single positive number.", call. = FALSE)

  structure(
    list(title    = title,
         subtitle = subtitle,
         caption  = caption,
         ylim     = ylim,
         yint     = yint,
         flip     = flip,
         colors   = colors,
         hc_theme = hc_theme),
    class = "fig_opts"
  )
}

# ── S3 methods ───────────────────────────────────────────────────────────────

#' @export
print.fig_opts <- function(x, ...) {
  cat("<fig_opts>\n")
  if (!is.null(x$title))    cat("  title    :", x$title,    "\n")
  if (!is.null(x$subtitle)) cat("  subtitle :", x$subtitle, "\n")
  if (!is.null(x$caption))  cat("  caption  :", x$caption,  "\n")
  if (!is.null(x$ylim))     cat("  ylim     :", x$ylim,     "\n")
  cat("  yint     :", x$yint, "\n")
  cat("  flip     :", x$flip, "\n")
  if (!is.null(x$colors))
    cat("  colors   :", paste(x$colors, collapse = ", "), "\n")
  if (!is.null(x$hc_theme)) cat("  hc_theme :", x$hc_theme, "\n")
  invisible(x)
}

#' @export
as.list.fig_opts <- function(x, ...) unclass(x)

# ── Internal default ─────────────────────────────────────────────────────────

#' @keywords internal
default_opts <- function() fig_opts()
