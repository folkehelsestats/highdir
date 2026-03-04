# R/backend.R ── Backend engine functions
#
# Engine contract:
#   function(spec, geom, opts, geom_params, use_js, filename, ...)
#
# `geom_params` is a named list built by hd_make() that carries *all*
# geom-specific arguments (smooth, dot_size, line_symbols, ymin, ymax, …).
# Passing them as an explicit list instead of bare `...` means:
#   1. The engine signature is stable regardless of how many geoms exist.
#   2. Nothing unexpected leaks into hc_add_series() causing tibble errors.

# ── ggplot2 engine ───────────────────────────────────────────────────────────

#' @keywords internal
ggplot_engine <- function(spec, geom, opts, geom_params,
                          use_js = TRUE, filename = NULL, ...) {

  # ── Map geom: build from a blank ggplot (no axis mapping from base_fig) ──
  if (!is.null(geom$is_map_geom) && isTRUE(geom$is_map_geom)) {
    layers <- geom$ggplot_fun(spec, opts, geom_params)
    p <- ggplot2::ggplot() +
      ggplot2::labs(
        title    = opts$title,
        subtitle = opts$subtitle,
        caption  = opts$caption
      )
    for (layer in layers) p <- p + layer
    return(p)
  }

  p <- base_fig(spec, opts, "ggplot2")

  layers <- geom$ggplot_fun(spec, opts, geom_params)

  # geom functions return a list of layers; + works element-wise on ggplots
  for (layer in layers) p <- p + layer

  p <- apply_gg_colors(p, opts$colors)

  font <- getOption("highdir.font", default = NULL)
  if (!is.null(font))
    p <- p + ggplot2::theme(text = ggplot2::element_text(family = font))

  p
}

# ── highcharter engine ───────────────────────────────────────────────────────

#' @keywords internal
highcharter_engine <- function(spec, geom, opts, geom_params,
                               use_js = TRUE, filename = NULL, ...) {

  # ── Map geom builds its own fresh highchart(type="map") ──────────────────
  # The standard base_fig() canvas (x/y axes, yAxis etc.) is meaningless for
  # a choropleth — hc_map() returns a fully-formed map widget instead.
  if (!is.null(geom$is_map_geom) && isTRUE(geom$is_map_geom)) {
    return(geom$highcharter_fun(NULL, spec, opts, geom_params,
                                use_js = use_js, ...))
  }

  chart <- base_fig(spec, opts, "highcharter")

  # ── Tooltip ──────────────────────────────────────────────────────────────
  point_fmt <- if (is.null(spec$n)) {
    paste0(
      '<span style="color:{series.color}">\u25CF</span> ',
      '<span style="color:black">{series.name}</span>: ',
      '<b>{point.y}%</b><br/>'
    )
  } else {
    paste0(
      '<span style="color:{series.color}">\u25CF</span> ',
      '<span style="color:black">{series.name}</span>: ',
      '<b>{point.', spec$n, '} ({point.y}%)</b><br/>'
    )
  }

  chart <- chart |>
    highcharter::hc_tooltip(
      useHTML      = TRUE,
      shared       = TRUE,
      headerFormat =
        '<span style="font-size:14px;font-weight:bold;">{point.key}</span><br/>',
      pointFormat  = point_fmt
    ) |>
    highcharter::hc_credits(
      enabled = TRUE,
      text    = "Helsedirektoratet",
      href    = "https://www.helsedirektoratet.no/"
    ) |>
    highcharter::hc_legend(
      align         = "left",
      verticalAlign = "bottom",
      layout        = "horizontal",
      x             = 50, y = 0
    ) |>
    highcharter::hc_exporting(
      enabled       = TRUE,
      filename      = filename %||% "highdir-figure",
      accessibility = list(enabled = TRUE)
    ) |>
    # Accessibility module always loaded — not controlled by use_js
    highcharter::hc_add_dependency(name = "modules/accessibility.js")

  # ── Series (geom renders here) ────────────────────────────────────────────
  chart <- geom$highcharter_fun(chart, spec, opts, geom_params,
                                use_js = use_js, ...)

  # ── Theme (per-figure opts$hc_theme overrides session default) ───────────
  chart <- chart |>
    highcharter::hc_add_theme(
      hd_theme(name   = opts$hc_theme,
               colors = opts$colors)
    )

  # ── Session-level JS plugins ──────────────────────────────────────────────
  for (plugin in getOption("highdir.js_plugins", default = character(0)))
    chart <- hd_add_js(chart, plugin = plugin)

  chart
}
