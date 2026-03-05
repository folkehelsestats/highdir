
# ════════════════════════════════════════════════════════════════════════════
# hd_opts ── presentation options
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
#' opts_en <- hd_opts(title = "Health survey",    subtitle = "All ages")
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
#' @return An S3 object of class `"hd_opts"`.
#'
#' @seealso [hd_spec()], [hd_make()], [hd_set_theme()]
#'
#' @examples
#' opts <- hd_opts(
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
hd_opts <- function(title    = NULL,
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
    class = "hd_opts"
  )
}

# ── S3 methods ───────────────────────────────────────────────────────────────

#' @export
print.hd_opts <- function(x, ...) {
  cat("<hd_opts>\n")
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
as.list.hd_opts <- function(x, ...) unclass(x)

# ── Internal default ─────────────────────────────────────────────────────────

#' @keywords internal
default_opts <- function() hd_opts()
