add_column <- function(chart, spec, ...) {
  highcharter::hc_add_series(
    chart,
    data = spec$data,
    type = "column",
    highcharter::hcaes_string(x = spec$x, y = spec$y),
    ...
  )
}

## add this .onLoad() instead in zzz.R to avoid circular imports alphabetically
## register_geom("column", add_column)
