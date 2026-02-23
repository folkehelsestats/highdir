#' @keywords internal
.onLoad <- function(libname, pkgname) {

  register_geom("line", add_line)
  register_geom("scatter", add_scatter)
  register_geom("column", add_column)
  register_geom("arearange", add_arearange,
                required_args = c("ymin", "ymax"))
}
