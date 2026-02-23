add_arearange <- function(chart, spec, ymin, ymax, ...) {

  stopifnot(ymin %in% names(spec$data))
  stopifnot(ymax %in% names(spec$data))

  chart |>
    highcharter::hc_add_series(
      data = spec$data,
      type = "arearange",
      highcharter::hcaes_string(
        x = spec$x,
        low = ymin,
        high = ymax
      ),
      ...
    )
}

## add this .onLoad() instead in zzz.R to avoid circular imports alphabetically
## register_geom("arearange", add_arearange, required_args = c("ymin", "ymax"))
