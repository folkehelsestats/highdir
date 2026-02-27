# make-figure.R — The main user-facing entry point

#' Build a Figure from a Specification
#'
#' Renders a [fig_spec] object using the selected backend. This is the primary
#' function users call after constructing a specification with [fig_spec()].
#'
#' @param spec A [fig_spec] object created by [fig_spec()].
#' @param type Character. Geometry to use. One of the values returned by
#'   [list_geoms()]: `"column"`, `"line"`, `"scatter"`, `"arearange"`, or
#'   any custom geometry registered with [register_geom()].
#' @param backend Character. Rendering backend. One of `"highcharter"`
#'   (default, interactive) or `"ggplot2"` (static), or any backend
#'   registered with [register_backend()].
#' @param use_js Logical. Whether to include manually-injected JavaScript
#'   enhancements in the highcharter output. Tooltips, hover states, the
#'   accessibility module, and all other declarative Highcharts features are
#'   **always** included regardless of this setting. When `TRUE` (default), a
#'   `htmlwidgets::JS()` hover band is added behind the active category
#'   column/point via `point.events.mouseOver` / `mouseOut`. Set to `FALSE`
#'   to omit that custom callback, e.g. when you want a clean widget with no
#'   hand-written JS. Has no effect for the ggplot2 backend.
#' @param filename Character or `NULL`. Base filename used by the Highcharts
#'   built-in export menu (no extension). Defaults to `"highdir-figure"`.
#'   Ignored for the ggplot2 backend.
#' @param smooth Logical. For `type = "line"` only. Use spline interpolation
#'   for smooth curves (`TRUE`, default) or straight line segments (`FALSE`).
#' @param dot_size Numeric. For `type = "line"` only. Radius of line markers
#'   in pixels. Default `4`.
#' @param line_symbols Character vector or `NULL`. For `type = "line"` only.
#'   Marker symbol for each group. Valid values: `"circle"`, `"square"`,
#'   `"diamond"`, `"triangle"`, `"triangle-down"`. When `NULL` symbols are
#'   assigned automatically.
#' @param colors Character vector or `NULL`. Colour overrides for this figure
#'   only. When `NULL` the palette from [hd_set_theme()] (or the hdir
#'   default palette) is used.
#' @param ... Additional arguments forwarded to the geometry's render
#'   function. Required arguments for a geometry (e.g. `ymin` / `ymax` for
#'   `"arearange"`) must be supplied here.
#'
#' @return A `highchart` widget (when `backend = "highcharter"`) or a
#'   `ggplot` object (when `backend = "ggplot2"`).
#'
#' @examples
#' df <- data.frame(
#'   age  = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
#'   sex  = rep(c("Male", "Female"), 4),
#'   pct  = c(42, 38, 55, 61, 48, 52, 60, 57),
#'   n    = c(120, 115, 200, 210, 180, 175, 160, 155)
#' )
#'
#' spec <- fig_spec(
#'   data     = df,
#'   x        = "age",
#'   y        = "pct",
#'   group    = "sex",
#'   n        = "n",
#'   title    = "Health survey results",
#'   subtitle = "Source: Example data",
#'   caption  = "Tall om helse"
#' )
#'
#' \dontrun{
#' # Interactive highcharter column chart (default)
#' make_fig(spec, "column")
#'
#' # Same data as a smooth line chart — with JS hover effects
#' make_fig(spec, "line", smooth = TRUE)
#'
#' # Disable JS (e.g. for self-contained HTML export)
#' make_fig(spec, "column", use_js = FALSE)
#'
#' # Static ggplot2 version
#' make_fig(spec, "column", backend = "ggplot2")
#'
#' # Arearange needs extra required args
#' spec2 <- fig_spec(df, x = "age", y = "pct", group = "sex")
#' make_fig(spec2, "arearange", ymin = "pct_lo", ymax = "pct_hi")
#' }
#'
#' @seealso [fig_spec()], [hd_save()], [hd_set_theme()], [list_geoms()],
#'   [list_backends()], [run_app()]
#'
#' @export
make_fig <- function(spec,
                     type         = "column",
                     backend      = "highcharter",
                     use_js       = TRUE,
                     filename     = NULL,
                     smooth       = TRUE,
                     dot_size     = 4,
                     line_symbols = NULL,
                     colors       = NULL,
                     ...) {

  # ---- Input validation ------------------------------------------------------
  if (!inherits(spec, "fig_spec"))
    stop("`spec` must be a fig_spec object created by fig_spec().", call. = FALSE)

  geom <- get_geom(type)
  if (is.null(geom))
    stop("Unknown geometry '", type, "'. ",
         "Available: ", paste(list_geoms(), collapse = ", "), call. = FALSE)

  engine <- get_backend(backend)
  if (is.null(engine))
    stop("Unknown backend '", backend, "'. ",
         "Available: ", paste(list_backends(), collapse = ", "), call. = FALSE)

  # Check required args for this geom
  extra_args <- list(...)
  validate_geom_args(geom, extra_args)

  # ---- Dispatch --------------------------------------------------------------
  # Engine-level args (use_js, filename, colors) and line-specific args
  # (smooth, dot_size, line_symbols) are passed as explicit named arguments
  # so they are consumed by the engine / geom and never leak into
  # hc_add_series() via ... (which would cause tibble to reject NULL columns).
  engine(
    spec     = spec,
    geom     = geom,
    use_js   = use_js,
    filename = filename,
    colors   = colors,
    # line-specific — consumed by hc_line / gg_line, ignored by others
    smooth       = smooth,
    dot_size     = dot_size,
    line_symbols = line_symbols,
    ...
  )
}
