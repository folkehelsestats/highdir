# R/zzz.R ── Package load hook

#' @keywords internal
.onLoad <- function(libname, pkgname) {

  # ── Built-in colour palettes ───────────────────────────────────────────────
  register_palette("hdir",
                   c(
                     "#025169", "#0069E8",
                     "#7C145C", "#047FA4",
                     "#C68803", "#38A389",
                     "#6996CE", "#366558",
                     "#BF78DE", "#767676"
                   ))

  register_palette("hdir2", c("#315975", "#8A294D"))

  # ── Backends ──────────────────────────────────────────────────────────────
  register_backend("ggplot2",     ggplot_engine)
  register_backend("highcharter", highcharter_engine)

  # ── Geometries ────────────────────────────────────────────────────────────
  register_geom("column",
    ggplot_fun      = gg_column,
    highcharter_fun = hc_column
  )

  register_geom("line",
    ggplot_fun      = gg_line,
    highcharter_fun = hc_line
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

  register_geom("pie",
    ggplot_fun      = gg_pie,
    highcharter_fun = hc_pie
  )

  register_geom(
    "ranked_bar",
    ggplot_fun     = gg_ranked_bar,
    highcharter_fun = hc_ranked_bar,
    required_args  = character(0),
    is_map_geom    = FALSE
  )

  ## register_geom("map",
  ##   ggplot_fun      = gg_map,
  ##   highcharter_fun = hc_map,
  ##   is_map_geom     = TRUE
  ## )

  # ── Option defaults (skip any pre-set in .Rprofile) ───────────────────────
  op     <- options()
  to_set <- .hd_defaults[!names(.hd_defaults) %in% names(op)]
  if (length(to_set)) options(to_set)

  invisible()
}
