# highdir-package.R — Package-level documentation

#' highdir: Backend-Agnostic Figure Builder
#'
#' @description
#' `highdir` provides a unified API for building interactive figures with
#' **highcharter** or static figures with **ggplot2**. A figure is described
#' once as a [fig_spec] object and rendered to either backend without
#' changing the calling code.
#'
#' ## Quick start
#'
#' ```r
#' library(highdir)
#'
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
#' # Interactive highcharter chart (default)
#' make_fig(spec, "column")
#'
#' # Same spec, static ggplot2 version
#' make_fig(spec, "column", backend = "ggplot2")
#'
#' # Smooth line chart without JS hover effects
#' make_fig(spec, "line", smooth = TRUE, use_js = FALSE)
#'
#' # Save to disk
#' hd_save(make_fig(spec, "column"), "chart.html")
#' ```
#'
#' ## Key functions
#'
#' | Function | Purpose |
#' |:---|:---|
#' | [fig_spec()] | Create a backend-agnostic figure specification |
#' | [make_fig()] | Render a spec to highcharter or ggplot2 |
#' | [hd_save()] | Export a figure to HTML / JSON / PNG / SVG / PDF |
#' | [hd_set_theme()] | Set package-wide colour, font, and theme defaults |
#' | [hd_theme()] | Build a highcharter theme object |
#' | [hd_add_js()] | Inject custom JavaScript into a highchart widget |
#' | [run_app()] | Launch the interactive Shiny GUI |
#' | [register_geom()] | Add a custom geometry |
#' | [register_backend()] | Add a custom rendering backend |
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom rlang .data sym `!!`
#' @importFrom utils head modifyList
#' @importFrom stats setNames
#' @importFrom tools file_ext file_path_sans_ext
## usethis namespace: end
NULL
