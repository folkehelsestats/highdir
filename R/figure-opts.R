#
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
#' opts_no <- hd_opts(title = "Helseundersøkelse", subtitle = "Alle aldre")
#'
#' hd_make(spec, "column", opts_en)
#' hd_make(spec, "column", opts_no)
#' ```
#'
#' @param title       Character or `NULL`. Chart title.
#' @param subtitle    Character or `NULL`. Subtitle. Highcharter default:
#'   `"Kilde: Navn av kilder"`.
#' @param caption     Character or `NULL`. Caption text displayed below the
#'   figure (highcharter only). This is a **visible** footnote, distinct from
#'   `description` which is read only by assistive technology.
#' @param description Character or `NULL`. Invisible accessibility description
#'   of the figure intended for screen readers and other assistive technology.
#'   \describe{
#'     \item{highcharter}{Passed to `hc_accessibility(description = ...)`.
#'       Requires the accessibility module, which highdir loads automatically.
#'       Screen readers announce this text when the user focuses the chart.}
#'     \item{ggplot2}{Set as the `alt` label via `labs(alt = ...)`, available
#'       since ggplot2 3.3.0.  Rendered as an HTML `alt` attribute when the
#'       plot is saved to SVG or included in an R Markdown / Quarto document
#'       with `fig.alt` support.}
#'   }
#'   Write a concise one- or two-sentence summary of what the figure shows,
#'   including the key trend or comparison, so the information is equally
#'   accessible to users who cannot see the chart.  Example:
#'   `"Bar chart showing alcohol use by age group. Use is highest in the
#'   45-54 age group at 65% and lowest in 18-24 at 42%."`
#' @param xlab        Character or `NULL`. X-axis label. \describe{
#'   \item{`" "` (default)}{Use the `x` column name from [hd_spec()].}
#'   \item{`NULL`}{Hide the x-axis label completely.}
#'   \item{any string}{Use that string as the label.} }
#' @param ylab        Character or `NULL`. Y-axis label. Same rules as `xlab`.
#' @param ylim        Numeric vector of length 2 or `NULL`. Fixed y-axis
#'   limits, e.g. `c(0, 100)`.
#' @param yint        Positive numeric. Y-axis tick interval. Default `10`.
#' @param ysuffix     Character or `NULL`. String appended to every y-axis
#'   tick label, e.g. `"%"` or `" km"`. `NULL` shows no suffix.
#' @param xtick_labels Character or `NULL`. Column name supplying custom
#'   x-axis tick labels when the plotted x-values are numeric but the
#'   displayed labels should come from another column. Highcharter only.
#'   Note: Highcharts indexes categories from 0, not 1.
#' @param decimals    Integer or `NULL`. Number of decimal places to round
#'   the y-values to before rendering. Applied to the data via
#'   `check_decimals()` in [hd_make()]. `NULL` leaves values unchanged.
#' @param flip        Logical. Invert axes (horizontal bars / inverted chart).
#'   Default `FALSE`.
#' @param colors      Character vector, palette name string, or `NULL`.
#'   Per-figure colour override; takes precedence over [hd_set_theme()].
#' @param hc_theme    Character or `NULL`. Per-figure highcharter theme name;
#'   takes precedence over [hd_set_theme()]. See [hd_theme()] for valid names.
#' @param gg_theme    Character name string, ggplot2 theme object, or `NULL`.
#'   Per-figure ggplot2 theme; takes precedence over [hd_set_theme()].
#'   Name strings: `"classic"` (default), `"minimal"`, `"bw"`, `"light"`,
#'   `"dark"`, `"void"`, `"grey"`. Or pass a `ggplot2::theme_*()` object
#'   directly, e.g. `ggplot2::theme_bw(base_size = 14)`.
#'
#' @return An S3 object of class `"hd_opts"`.
#'
#' @seealso [hd_spec()], [hd_make()], [hd_set_theme()]
#'
#' @examples
#' opts <- hd_opts(
#'   title       = "Health survey results",
#'   subtitle    = "Source: FHI 2024",
#'   caption     = "Tall om helse",
#'   description = paste(
#'     "Grouped bar chart showing alcohol use by age group and sex.",
#'     "Use is highest in the 45-54 age group at 65% for women."
#'   ),
#'   ylim        = c(0, 100),
#'   yint        = 20,
#'   colors      = c("#025169", "#7C145C")
#' )
#' opts
#'
#' @export
hd_opts <- function(title        = NULL,
                    subtitle     = NULL,
                    caption      = NULL,
                    description  = NULL,
                    xlab         = " ",
                    ylab         = " ",
                    ylim         = NULL,
                    yint         = 10,
                    ysuffix      = NULL,
                    xtick_labels = NULL,
                    decimals     = NULL,
                    flip         = FALSE,
                    colors       = NULL,
                    hc_theme     = NULL,
                    gg_theme     = NULL
                    ) {

  check_ylim(ylim)
  if (!is.numeric(yint) || length(yint) != 1 || yint <= 0)
    stop("`yint` must be a single positive number.", call. = FALSE)
  if (!is.null(description) && (!is.character(description) || length(description) != 1L))
    stop("`description` must be a single character string or NULL.", call. = FALSE)

  structure(
    list(title        = title,
         subtitle     = subtitle,
         caption      = caption,
         description  = description,
         xlab         = xlab,
         ylab         = ylab,
         ylim         = ylim,
         yint         = yint,
         ysuffix      = ysuffix,
         xtick_labels = xtick_labels,
         decimals     = decimals,
         flip         = flip,
         colors       = colors,
         hc_theme     = hc_theme,
         gg_theme     = gg_theme
         ),
    class = "hd_opts"
  )
}

# -- S3 methods ----------------------------------------------------------------

#' @export
print.hd_opts <- function(x, ...) {
  cat("<hd_opts>\n")
  if (!is.null(x$title))       cat("  title        :", x$title,       "\n")
  if (!is.null(x$subtitle))    cat("  subtitle     :", x$subtitle,    "\n")
  if (!is.null(x$caption))     cat("  caption      :", x$caption,     "\n")
  if (!is.null(x$description)) {
    # Truncate long descriptions in print output for readability
    desc_print <- if (nchar(x$description) > 80)
      paste0(substr(x$description, 1, 77), "...")
    else
      x$description
    cat("  description  :", desc_print, "\n")
  }
  if (!is.null(x$xlab))        cat("  xlab         :", x$xlab,        "\n")
  if (!is.null(x$ylab))        cat("  ylab         :", x$ylab,        "\n")
  if (!is.null(x$ylim))        cat("  ylim         :", x$ylim,        "\n")
  cat("  yint         :", x$yint, "\n")
  if (!is.null(x$ysuffix))     cat("  ysuffix      :", x$ysuffix,     "\n")
  if (!is.null(x$xtick_labels)) cat("  xtick_labels :", format(x$xtick_labels), "\n")
  if (!is.null(x$decimals))    cat("  decimals     :", x$decimals,    "\n")
  cat("  flip         :", x$flip, "\n")
  if (!is.null(x$colors))
    cat("  colors       :", paste(x$colors, collapse = ", "), "\n")
  if (!is.null(x$hc_theme))    cat("  hc_theme     :", x$hc_theme,    "\n")
  if (!is.null(x$gg_theme))    cat("  gg_theme     :", format(x$gg_theme), "\n")
  invisible(x)
}

#' @export
as.list.hd_opts <- function(x, ...) unclass(x)

# -- Internal default ----------------------------------------------------------

#' @keywords internal
default_opts <- function() hd_opts()
