#' @keywords internal
.onLoad <- function(libname, pkgname) {

  register_backend("ggplot2", ggplot_engine)
  register_backend("highcharter", highcharter_engine)

  register_geom("line", gg_line, hc_line)
  register_geom("scatter", gg_scatter, hc_scatter)
  register_geom("column", gg_column, hc_column)
  register_geom("arearange", gg_arearange, hc_arearange,
                required_args = c("ymin", "ymax"))
}
