# COLUMN
# ------------------------------------------------------------------------------
# Each geometry is a pair:
#   gg_<name>  -> returns a ggplot2 layer (or list of layers)
#   hc_<name>  -> adds series to a highchart object, returns the updated chart
#
# Calling convention (enforced by the registry):
#   gg_*:  function(spec, opts, geom_params, ...)
#   hc_*:  function(chart, spec, opts, geom_params, use_js, ...)
#
# geom_params is a named list carrying all geom-specific args so that the
# engine signature stays stable as new geoms are added.  Nothing leaks into
# hc_add_series() via bare `...`.

#' @keywords internal
gg_column <- function(spec, opts, geom_params) {
  sc <- geom_params$single_colour

  list(
    if (!is.null(sc)) {
      # Single series: inject brand colour as fixed aesthetic
      ggplot2::geom_col(
        position = "dodge",
        fill = sc,
        colour = sc
      )
    } else {
      # Multi-series: no fixed colour - inherits from mapped aesthetic
      ggplot2::geom_col(position = "dodge")
    }
  )
}


#' @keywords internal
hc_column <- function(chart, spec, opts, geom_params, use_js = TRUE, ...) {
  groups   <- .group_split(spec)
  palette  <- resolve_colors(length(groups), opts$colors)
  point_ev <- point_events_or_null(use_js)
  xmap     <- .hc_x_map(spec)

  for (i in seq_along(groups)) {
    grp  <- groups[[i]]
    args <- list(
      chart,
      data   = xmap$data[grp$rows, ],
      type   = "column",
      name   = grp$name,
      xmap$mapping,
      color  = palette[i],
      states = list(hover = list(brightness = 0.2))
    )
    if (!is.null(point_ev)) args$point <- point_ev
    chart <- do.call(highcharter::hc_add_series, args)
  }
  chart
}

## -----------------------------------------------------------------------------
## Public constructor for column geometry layer.  See ?hd for usage.
## -----------------------------------------------------------------------------

#' Column Geometry Layer for hd Objects
#'
#' `hd_geom_column()` creates a column geometry layer that is added to an [hd()]
#' object via `+`.  The layer records the geometry type and any geometry-specific
#' arguments; rendering only happens when the `hd` object is printed.
#'
#' @param ... Geometry-specific arguments forwarded to [hd_make()].
#'
#' @return An S3 object of class `"hd_geom"` for use with `+.hd`.
#' @examples
#' 
#' survey <- data.frame(
#'   age_group = rep(c("18-24", "25-34", "35-44", "45-54", "55-64"), each = 2),
#'   kjonn       = rep(c("Male", "Female"), times = 5),
#'   pct       = c(42, 38, 55, 61, 48, 52, 60, 57, 65, 70),
#'   n         = c(120, 115, 200, 210, 180, 175, 160, 155, 140, 145)
#' )
#'
#' spec_col <- hd_spec(survey,
#'                     x     = "age_group",
#'                     y     = "pct",
#'                     group = "kjonn",
#'                     n     = "n")
#'
#' opts_col <- hd_opts(
#'   title    = "Alcohol use by age group and kjonn",
#'   subtitle = "Source: Norwegian Directorate of Health",
#'   ylim     = c(0, 100),
#'   yint     = 20,
#'   ylab     = "Percentage (%)"
#' )
#'
#' # Interactive (default)
#' hd_make(spec_col, "column", opts_col)
#'
#' # Static ggplot2
#' hd_make(spec_col, "column", opts_col, backend = "ggplot2")
#'
#' # Composable style
#' p <- hd(survey, x = "age_group", y = "pct", group = "kjonn")
#' p2 <- p + hd_geom_column()
#'
#' # More options
#' p2 + hd_opts(title = "Health survey", ylim = c(0, 100))
#'
#' # Pass an existing hd_spec
#' spec <- hd_spec(survey, x = "age_group", y = "pct", group = "kjonn", n = "n")
#'
#' hd(spec, backend = "ggplot2") +
#'  hd_geom_column() +
#'  hd_opts(title = "Health survey", ylim = c(0, 80))
#' 
#' @export
hd_geom_column <- function(...) {
  hd_geom("column", ...)
}
