# zzz.R — Package load / unload hooks

#' @keywords internal
.onLoad <- function(libname, pkgname) {

  # -- Register backends -------------------------------------------------------
  register_backend("ggplot2",     ggplot_engine)
  register_backend("highcharter", highcharter_engine)

  # -- Register geometries -----------------------------------------------------
  register_geom("line",
    ggplot_fun      = gg_line,
    highcharter_fun = hc_line
  )
  register_geom("column",
    ggplot_fun      = gg_column,
    highcharter_fun = hc_column
  )
  register_geom("scatter",
    ggplot_fun      = gg_scatter,
    highcharter_fun = hc_scatter
  )
  register_geom("arearange",
    ggplot_fun      = gg_arearange,
    highcharter_fun = hc_arearange,
    required_args   = c("ymin", "ymax")
  )

  # -- Set package option defaults (skip any the user pre-set in .Rprofile) ---
  op      <- options()
  to_set  <- .hd_defaults[!names(.hd_defaults) %in% names(op)]
  if (length(to_set)) options(to_set)

  invisible()
}
