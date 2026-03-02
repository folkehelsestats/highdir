# backend.R — Backend engine functions
#
# Each engine receives (spec, geom, ...) and returns a finished figure.
# Engines are responsible for:
#   1. Building the blank canvas via base_fig()
#   2. Calling the geom's render function
#   3. Applying the theme / colour / font layer
#   4. Adding the accessibility module and export for highcharter
#
# IMPORTANT: Every argument that make_fig() forwards explicitly (use_js,
# filename, colors, smooth, dot_size, line_symbols) must be listed as a
# named parameter in BOTH the engine signature AND the geom call so they are
# never included in the bare ... that reaches hc_add_series(). Passing NULL
# values via ... into hc_add_series() causes tibble to throw
# "column is NULL" errors.

# ---------------------------------------------------------------------------
# ggplot2 engine
# ---------------------------------------------------------------------------

#' @keywords internal
ggplot_engine <- function(spec, geom,
                           use_js       = TRUE,   # accepted but ignored
                           filename     = NULL,   # accepted but ignored
                           colors       = NULL,
                           smooth       = FALSE,
                           dot_size     = 4,
                           line_symbols = NULL,   # accepted but ignored for gg
                           ...) {
  p <- base_fig(spec, "ggplot2")
  # Only pass smooth / dot_size; the gg_* functions consume what they need
  p <- p + geom$ggplot_fun(spec, smooth = smooth, dot_size = dot_size, ...)
  p <- apply_gg_colors(p, colors)

  font <- getOption("highdir.font", default = NULL)
  if (!is.null(font))
    p <- p + ggplot2::theme(text = ggplot2::element_text(family = font))

  p
}

# ---------------------------------------------------------------------------
# highcharter engine
# ---------------------------------------------------------------------------

#' @keywords internal
highcharter_engine <- function(spec, geom,
                                use_js       = TRUE,
                                filename     = NULL,
                                colors       = NULL,
                                smooth       = FALSE,
                                dot_size     = 4,
                                line_symbols = NULL,
                                ...) {
  chart <- base_fig(spec, "highcharter")

  # Add categories to x-axis for character x variables (shared by all geoms)
  if (!is.numeric(spec$data[[spec$x]])) {
    x_cats <- unique(spec$data[[spec$x]])
    chart <- chart |>
      highcharter::hc_xAxis(
        title        = list(text = spec$xlab %||% " "),
        categories   = x_cats,
        tickInterval = 1,
        labels       = list(step = 1)
      )
  }

  # Build tooltip (show count alongside percentage when spec$n is provided)
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
      headerFormat = '<span style="font-size:14px;font-weight:bold;">{point.key}</span><br/>',
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
      x             = 50,
      y             = 0
    ) |>
    highcharter::hc_exporting(
      enabled       = TRUE,
      filename      = filename %||% "highdir-figure",
      accessibility = list(enabled = TRUE)
    )

  # Accessibility module — always loaded regardless of use_js.
  # use_js only controls manually-injected htmlwidgets::JS() callbacks.
  chart <- chart |>
    highcharter::hc_add_dependency(name = "modules/accessibility.js")

  # Add series via the geom.
  # Pass only the args each geom signature declares; keep ... clean of
  # engine-level args so nothing unexpected reaches hc_add_series().
  chart <- geom$highcharter_fun(
    chart,
    spec,
    use_js       = use_js,
    colors       = colors,
    smooth       = smooth,
    dot_size     = dot_size,
    line_symbols = line_symbols,
    ...
  )

  # Apply highcharter theme (reads hd_set_theme() options)
  chart <- chart |> highcharter::hc_add_theme(hd_theme())

  # Inject any session-level JS plugins
  plugins <- getOption("highdir.js_plugins", default = character(0))
  for (plugin in plugins) {
    chart <- hd_add_js(chart, plugin = plugin)
  }

  chart
}
