add_scatter <- function(chart, spec, ...) {
  highcharter::hc_add_series(
    chart,
    data = spec$data,
    type = "scatter",
    highcharter::hcaes_string(x = spec$x, y = spec$y),
    ...
  )
}

## add this .onLoad() instead in zzz.R to avoid circular imports alphabetically
## register_geom("scatter", add_scatter)
