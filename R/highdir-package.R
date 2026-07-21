# R/highdir-package.R -- Package-level documentation and global imports

#' highdir: Backend-Agnostic Figure Builder for Helsedirektoratet
#'
#' @description
#' **highdir** provides a unified API for building interactive figures with
#' **highcharter** or static figures with **ggplot2**.  A figure is described
#' once as a data-mapping object ([hd_spec]) and an optional presentation
#' object ([hd_opts]), then rendered to either backend without changing the
#' calling code.
#'
#' ## Core workflow
#'
#' ```r
#' library(highdir)
#'
#' # -- 1. Sample data --------------------------------------------------------
#' df <- data.frame(
#'   age = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
#'   sex = rep(c("Male", "Female"), 4),
#'   pct = c(42, 38, 55, 61, 48, 52, 60, 57),
#'   n   = c(120, 115, 200, 210, 180, 175, 160, 155)
#' )
#'
#' # -- 2. Describe the data mapping (once) ----------------------------------
#' spec <- hd_spec(df, x = "age", y = "pct", group = "sex", n = "n",
#'                  ylab = "Percentage (%)")
#'
#' # -- 3. Describe the presentation (reusable across specs) -----------------
#' opts <- hd_opts(title    = "Health survey results",
#'                  subtitle = "Source: FHI 2024",
#'                  caption  = "Tall om helse",
#'                  ylim     = c(0, 80))
#'
#' # -- 4. Render — swap backend without touching spec or opts ----------------
#' hd_make(spec, "column", opts)                        # interactive HC
#' hd_make(spec, "column", opts, backend = "static")   # static ggplot2
#' hd_make(spec, "line",   opts, smooth = TRUE)         # HC spline
#' hd_make(spec, "line",   opts, backend = "static")   # gg line
#' hd_make(spec, "scatter")                             # HC scatter
#'
#' # Donut chart
#' hd_make(pie_spec, "pie", pie_opts, inner_size = "50%")
#'
#' # -- 5. Arearange (confidence intervals) ----------------------------------
#' df2   <- cbind(df, lo = df$pct - 5, hi = df$pct + 5)
#' spec2 <- hd_spec(df2, "age", "pct", group = "sex")
#' hd_make(spec2, "arearange", opts, ymin = "lo", ymax = "hi")
#'
#' # -- 6. Save to disk -------------------------------------------------------
#' hd_save(hd_make(spec, "column", opts),               "chart.html")
#' hd_save(hd_make(spec, "column", opts, backend="static"), "chart.png")
#'
#' # -- 7. Session-wide styling -----------------------------------------------
#' hd_set_theme(hc_theme = "economist",
#'              colors   = c("#025169","#7C145C","#C68803"))
#'
#' # -- 8. Launch the Shiny GUI -----------------------------------------------
#' hd_app()
#' ```
#'
#' ## Key functions
#'
#' | Function | Purpose |
#' |:--|:--|
#' | [hd_spec()] | Describe data mapping (x, y, group, n, labels) |
#' | [hd_opts()] | Describe presentation (title, ylim, colours, theme) |
#' | [hd_make()] | Render spec + opts → highchart or ggplot |
#' | [hd_save()] | Export to HTML / JSON / PNG / SVG / PDF |
#' | [hd_set_theme()] | Session-wide colour / font / theme defaults |
#' | [hd_theme()] | Build a highcharter theme object directly |
#' | [hd_add_js()] | Inject custom JS into a highchart |
#' | [register_geom()] | Add a custom geometry |
#' | [register_backend()] | Add a custom rendering backend |
#' | [register_palette()] | Add a named colour palette |
#' | [list_geoms()] | Show available geometries |
#' | [list_backends()] | Show available backends |
#' | [list_palettes()] | Show available palettes |
#' | [hd_app()] | Launch the Shiny GUI |
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom rlang .data
#' @importFrom utils modifyList head
#' @importFrom stats setNames
#' @importFrom tools file_ext file_path_sans_ext
## usethis namespace: end
NULL
