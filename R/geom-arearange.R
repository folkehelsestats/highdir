# ════════════════════════════════════════════════════════════════════════════
# AREARANGE
# ════════════════════════════════════════════════════════════════════════════
# Each geometry is a pair:
#   gg_<name>  → returns a ggplot2 layer (or list of layers)
#   hc_<name>  → adds series to a highchart object, returns the updated chart
#
# Calling convention (enforced by the registry):
#   gg_*:  function(spec, opts, geom_params, ...)
#   hc_*:  function(chart, spec, opts, geom_params, use_js, ...)
#
# geom_params is a named list carrying all geom-specific args so that the
# engine signature stays stable as new geoms are added.  Nothing leaks into
# hc_add_series() via bare `...`.

#' @keywords internal
gg_arearange <- function(spec, opts, geom_params) {
  sc   <- geom_params$single_colour

  # required args
  ymin <- geom_params$ymin
  ymax <- geom_params$ymax

  ## show main line
  show_line <- isTRUE(geom_params$show_line %||% TRUE)

  if (!is.null(sc)) {
    layers <- list(
      ggplot2::geom_ribbon(ggplot2::aes(ymin = .data[[ymin]],
                                        ymax = .data[[ymax]]),
                           fill = sc, alpha = 0.25),
      ggplot2::geom_line(colour = sc, linewidth = 0.8),
      ggplot2::geom_point(colour = sc, size = 2)
    )
  } else {
    layers <- list(
      ggplot2::geom_ribbon(ggplot2::aes(ymin = .data[[ymin]],
                                        ymax = .data[[ymax]]),
                           alpha = 0.25),
      ggplot2::geom_line(linewidth = 0.8),
      ggplot2::geom_point(size = 2)
    )
  }

  # Centre line added on top of the ribbon
  if (show_line) {
    layers <- c(layers, list(
      ggplot2::geom_line(linewidth = 0.8),
      ggplot2::geom_point(size = 3, shape = 21, fill = "white", stroke = 1.2)
    ))
  }

  layers
}

#' @keywords internal
hc_arearange <- function(chart, spec, opts, geom_params, use_js = TRUE, ...) {
  ## required args
  ymin     <- geom_params$ymin
  ymax     <- geom_params$ymax

  ## Show main line
  show_line <- isTRUE(geom_params$show_line %||% TRUE)

  groups   <- .group_split(spec)
  palette  <- resolve_colors(length(groups), opts$colors)
  point_ev <- point_events_or_null(use_js)

  for (i in seq_along(groups)) {
    grp     <- groups[[i]]
    color_i <- palette[i]

    # Each group gets a unique id so the arearange can link back to its line.
    # Without a unique id per group, all arearanges would link to the same line.
    line_id <- paste0("line_series_", i)

    # ── 1. Main line series ---------------------------------------------------
    # Added BEFORE the arearange so it renders on top in z-order.
    # id = line_id is what the arearange below will reference via linkedTo.
    # showInLegend = FALSE because the arearange entry already represents
    # this group in the legend — showing both would duplicate the label.
    if (show_line) {
      line_args <- list(
        chart,
        data         = spec$data[grp$rows, ],
        type         = "line",
        id           = line_id,         # anchor for linkedTo below
        name         = grp$name,
        highcharter::hcaes(
          x = !!rlang::sym(spec$x),
          y = !!rlang::sym(spec$y)      # spec$y is the centre/mean column
        ),
        color        = color_i,
        lineWidth    = 2,
        showInLegend = TRUE,            # this series owns the legend entry
        marker       = list(
          symbol  = "circle",
          enabled = TRUE,
          radius  = 4
        ),
        zIndex       = 2               # draw on top of the ribbon
      )
      if (!is.null(point_ev)) line_args$point <- point_ev
      chart <- do.call(highcharter::hc_add_series, line_args)
    }

    # ── 2. Arearange (confidence band) ----------------------------------------
    # linkedTo ties this ribbon to the line series above.
    # When the user clicks the legend entry (owned by the line), both
    # the line AND its ribbon hide together.
    # fillOpacity controls how transparent the band is.
    # showInLegend = FALSE because the line series already has the entry.
    range_args <- list(
      chart,
      data         = spec$data[grp$rows, ],
      type         = "arearange",
      name         = grp$name,
      linkedTo     = if (show_line) line_id else ":previous",
      highcharter::hcaes(
        x    = !!rlang::sym(spec$x),
        low  = !!rlang::sym(ymin),
        high = !!rlang::sym(ymax)
      ),
      color        = color_i,
      fillOpacity  = 0.15,            # subtle band, not a heavy block
      lineWidth    = 0,               # no border line on the ribbon edges
      showInLegend = !show_line       # only show in legend if no line
    )
    if (!is.null(point_ev)) range_args$point <- point_ev
    chart <- do.call(highcharter::hc_add_series, range_args)
  }

  chart
}
