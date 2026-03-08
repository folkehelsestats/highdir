# R/make-figure.R ── Primary user-facing entry point

#' Build a Figure from a Specification
#'
#' Renders a [hd_spec] and [hd_opts] pair using the selected backend and
#' geometry.  This is the central function of the package — everything else
#' feeds into or flows out of `hd_make()`.
#'
#' @section Workflow:
#' ```r
#' spec <- hd_spec(df, x = "age", y = "pct", group = "sex", n = "n")
#' opts <- hd_opts(title = "Health survey", ylim = c(0, 80))
#'
#' hd_make(spec, "column", opts)                       # highcharter (default)
#' hd_make(spec, "column", opts, backend = "ggplot2")  # static ggplot2
#' hd_make(spec, "line",   opts, smooth = TRUE)        # smooth spline
#' hd_make(spec, "pie",    opts)                       # pie / donut
#' ```
#'
#' @param spec      A [hd_spec] object from [hd_spec()].
#' @param type      Character.  Geometry name — one of [list_geoms()]:
#'   `"column"`, `"line"`, `"scatter"`, `"arearange"`, `"pie"`, or any
#'   custom geometry added with [register_geom()].
#' @param opts      A [hd_opts] object or `NULL` (uses all defaults).
#'   Controls title, subtitle, caption, ylim, yint, flip, per-figure
#'   colours, and highcharter theme.
#' @param backend   Character.  Rendering engine — `"highcharter"` (default,
#'   interactive) or `"ggplot2"` (static), or any engine added with
#'   [register_backend()].
#' @param use_js    Logical.  When `TRUE` (default) injects a hover-band
#'   `htmlwidgets::JS()` callback via `point.events.mouseOver/Out`.
#'   Tooltips, accessibility module, and all other Highcharts declarative
#'   features are **always** present.  Set `FALSE` for clean, no-custom-JS
#'   widgets.  Ignored by the ggplot2 backend.
#' @param module Use available modules js from CDN [https://api.highcharts.com/highcharts](https://api.highcharts.com/highcharts)
#' @param filename  Character or `NULL`.  Base filename for the Highcharts
#'   export menu (no extension).  Default: `"highdir-figure"`.
#' @param smooth    Logical.  `type = "line"` only — spline curves (`TRUE`,
#'   default) or straight segments (`FALSE`).
#' @param dot_size  Numeric.  `type = "line"` / `"scatter"` — marker radius
#'   in pixels.  Default `4`.
#' @param line_symbols Character vector or `NULL`.  `type = "line"` only —
#'   per-group Highcharts marker symbols.  Valid: `"circle"`, `"square"`,
#'   `"diamond"`, `"triangle"`, `"triangle-down"`.
#' @param inner_size Character or `NULL`.  `type = "pie"` only — inner
#'   radius as a CSS percentage string, e.g. `"50%"` for a donut chart.
#'   Default `"0%"` (solid pie).
#' @param ascending Logical. If \code{TRUE} (default) bars are sorted in
#'   ascending order of \code{y}.
#' @param comp Character string (partial match) identifying one category to
#'   highlight with a contrasting fill colour (\code{col2}). If omitted all
#'   bars use \code{col1}.
#' @param char_scale Numeric scaling factor that converts label character-count
#'   into axis-range units. Controls how generously space is estimated for each
#'   character. Defaults to \code{0.045}; increase (e.g. \code{0.06}) for
#'   larger text sizes, decrease (e.g. \code{0.03}) for smaller ones.
#' @param min_frac  Numeric. Minimum fraction of the axis range that a bar must
#'   span before its label is considered to fit inside. Acts as a safety floor
#'   for very short labels. Defaults to \code{0.08} (8 \%).
#' @param ...       Extra arguments forwarded to the geometry function.
#'   Required arguments (e.g. `ymin`, `ymax` for `"arearange"`) **must**
#'   be supplied here.
#'
#' @return A `highchart` widget (highcharter backend) or `ggplot` object
#'   (ggplot2 backend), invisibly wrapped so knitr/Shiny render it
#'   automatically.
#'
#' @seealso [hd_spec()], [hd_opts()], [hd_save()], [hd_set_theme()],
#'   [list_geoms()], [list_backends()], [hd_app()]
#'
#' @examples
#' df <- data.frame(
#'   age = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
#'   sex = rep(c("Male", "Female"), 4),
#'   pct = c(42, 38, 55, 61, 48, 52, 60, 57),
#'   n   = c(120, 115, 200, 210, 180, 175, 160, 155)
#' )
#'
#' spec <- hd_spec(df, x = "age", y = "pct", group = "sex", n = "n")
#'
#' opts <- hd_opts(title    = "Health survey results",
#'                  subtitle = "Source: FHI 2024",
#'                  ylim     = c(0, 80))
#'
#' \dontrun{
#' # ── Interactive charts (highcharter) ──────────────────────────────────────
#' hd_make(spec, "column", opts)
#' hd_make(spec, "line",   opts, smooth = TRUE)
#' hd_make(spec, "line",   opts, smooth = FALSE, dot_size = 6)
#' hd_make(spec, "scatter")
#'
#' # Pie chart — group is ignored; x = label, y = value
#' pie_df   <- data.frame(category = c("A","B","C","D"),
#'                         value    = c(35, 25, 20, 20))
#' pie_spec <- hd_spec(pie_df, x = "category", y = "value")
#' pie_opts <- hd_opts(title = "Share by category")
#' hd_make(pie_spec, "pie", pie_opts)
#' hd_make(pie_spec, "pie", pie_opts, inner_size = "50%")  # donut
#'
#' # Arearange — requires ymin + ymax in ...
#' df2   <- cbind(df, lo = df$pct - 5, hi = df$pct + 5)
#' spec2 <- hd_spec(df2, "age", "pct", group = "sex")
#' hd_make(spec2, "arearange", opts, ymin = "lo", ymax = "hi")
#'
#' # ── Disable JS hover band ─────────────────────────────────────────────────
#' hd_make(spec, "column", opts, use_js = FALSE)
#'
#' # ── Static ggplot2 versions ───────────────────────────────────────────────
#' hd_make(spec, "column",  opts, backend = "ggplot2")
#' hd_make(spec, "line",    opts, backend = "ggplot2")
#' hd_make(spec, "scatter", opts, backend = "ggplot2")
#' hd_make(pie_spec, "pie", pie_opts, backend = "ggplot2")
#'
#' # ── Reuse spec with different presentation ────────────────────────────────
#' opts_no <- hd_opts(title = "Helseundersøkelse", subtitle = "Alle aldre")
#' hd_make(spec, "column", opts_no)
#'
#' # ── Save outputs ──────────────────────────────────────────────────────────
#' hd_save(hd_make(spec, "column", opts),               "column.html")
#' hd_save(hd_make(spec, "column", opts, backend="ggplot2"), "column.png")
#' }
#'
#' @export
hd_make <- function(spec,
                    type        = "column",
                    opts        = NULL,
                    backend     = "highcharter",
                    use_js      = TRUE,
                    module      = TRUE,
                    filename    = NULL,
                    smooth      = TRUE,
                    dot_size    = 4,
                    line_symbols = NULL,
                    inner_size  = "0%",
                    ascending   = TRUE,
                    comp        = NULL,
                    aim         = NULL,
                    char_scale  = 0.045,
                    min_frac    = 0.08,
                    ...) {

  opts <- opts %||% default_opts()

  # Collect all geom-specific args into one list so the engine signature
  # stays stable as new geoms are added.
  extra_args  <- list(...)
  geom_params <- c(
    list(
      smooth       = smooth,
      dot_size     = dot_size,
      line_symbols = line_symbols,
      inner_size   = inner_size,
      ascending   = ascending,
      comp        = comp,
      aim         = aim,
      char_scale  = char_scale,
      min_frac    = min_frac
    ),
    extra_args
  )

  validate_fig_inputs(spec, opts, type, backend, extra_args)

  geom   <- get_geom(type)
  engine <- get_backend(backend)

  engine(
    spec        = spec,
    geom        = geom,
    opts        = opts,
    geom_params = geom_params,
    use_js      = use_js,
    module      = module,
    filename    = filename
  )
}
