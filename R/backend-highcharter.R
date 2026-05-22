#
# Engine contract:
#   function(spec, geom, opts, geom_params, use_js, filename, ...)
#
# `geom_params` is a named list built by hd_make() that carries *all*
# geom-specific arguments (smooth, dot_size, line_symbols, ymin, ymax, ...).
# Passing them as an explicit list instead of bare `...` means:
#   1. The engine signature is stable regardless of how many geoms exist.
#   2. Nothing unexpected leaks into hc_add_series() causing tibble errors.

# -- highcharter engine --------------------------------------------------------

#' @keywords internal
highcharter_engine <- function(spec, geom, opts, geom_params,
                               use_js = TRUE, module = FALSE, ...) {
  
  chart <- base_fig(spec, opts, "highcharter")
  
  # -- Tooltip -----------------------------------------------------------------
  ysuffix <- opts$ysuffix %||% ""
  has_suffix <- nzchar(ysuffix)

  series_header <- paste0(
    '<span style="color:{series.color}">\u25CF</span> ',
    '<span style="color:black">{series.name}</span>: '
  )

  y_fmt <- if (has_suffix) paste0('{point.y}', ysuffix) else '{point.y}'

  ysuffix_fmt <- paste0(series_header, '<b>', y_fmt, '</b><br/>')

  tools_fmt <- if (is.null(spec$n) || !nzchar(spec$n)) {
    paste0('<b>', y_fmt, '</b><br/>')
  } else {
    paste0('<b>{point.', spec$n, '} (', y_fmt, ')</b><br/>')
  }

  point_fmt <- if (is.null(spec$n) || !nzchar(spec$n)) ysuffix_fmt else paste0(series_header, tools_fmt)

  # -- Chart -------------------------------------------------------------------
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
      filename      = "highdir-figure",
      accessibility = list(enabled = TRUE)
    )

  # When to use FALSE:
  #   - embedding in apps where modules are loaded globally already via hc_function
  #   - unit tests where CDN access is unavailable
  #   - performance-critical contexts with many widgets on one page
  if (isTRUE(module)) {
    chart <- .hd_add_dep(chart, "plugins/accessibility.js")
  }

  # -- Series (geom renders here) ----------------------------------------------
  chart <- geom$highcharter_fun(chart, spec, opts, geom_params,
                                use_js = use_js, ...)

  # -- Theme (per-figure opts$hc_theme overrides session default) --------------
  # hd_theme() resolves name, colors, and font in one call -- same priority
  # chain as gg_theme() in ggplot_engine():
  #   explicit opts > getOption("highdir.*") > package default
  # Font is read from getOption("highdir.font") inside hd_theme() itself.
  chart <- chart |>
    highcharter::hc_add_theme(
      hd_theme(name   = opts$hc_theme,
               colors = opts$colors)
    )

  # -- Session-level JS plugins ------------------------------------------------
  for (plugin in getOption("highdir.js_plugins", default = character(0)))
    chart <- hd_add_js(chart, plugin = plugin)

  chart
}
