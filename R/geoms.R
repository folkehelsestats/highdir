# geoms.R — ggplot2 layer functions and highcharter series functions
#
# Each geometry is a pair: gg_<name> returns a ggplot2 layer, hc_<name>
# adds a series to a highchart and returns the updated chart.
#
# The JS hover-band effect (from graph.R) is factored out into a helper so
# it is shared across geoms and can be switched on/off via the `use_js`
# argument that travels through the backend engine.

# ---------------------------------------------------------------------------
# Shared JS hover-band helper
# ---------------------------------------------------------------------------

#' Build Highcharts hover-band point events JS
#'
#' Generates the `point.events.mouseOver` / `mouseOut` JavaScript that adds
#' a translucent highlight band behind the hovered category column.  Called
#' from every hc_* series function when `use_js = TRUE`.
#'
#' @param band_color Character. CSS colour for the band. Default is a soft
#'   blue: `"rgba(204, 211, 255, 0.25)"`.
#' @param half_width Numeric. Half the band width in category units.
#'   Default `0.4` gives a comfortable margin around a column.
#' @return A named list suitable for `point = list(events = ...)` in
#'   [highcharter::hc_add_series()].
#' @keywords internal
hc_hover_band_events <- function(band_color = "rgba(204, 211, 255, 0.25)",
                                  half_width  = 0.4) {
  mouse_over <- htmlwidgets::JS(sprintf(
    "function() {
       var chart = this.series.chart;
       var idx   = this.x;
       chart.xAxis[0].removePlotBand('hover-band');
       chart.xAxis[0].addPlotBand({
         id:    'hover-band',
         from:  idx - %s,
         to:    idx + %s,
         color: '%s',
         zIndex: 0
       });
     }",
    half_width, half_width, band_color
  ))

  mouse_out <- htmlwidgets::JS(
    "function() {
       this.series.chart.xAxis[0].removePlotBand('hover-band');
     }"
  )

  list(events = list(mouseOver = mouse_over, mouseOut = mouse_out))
}

#' Resolve point-events argument for hc_add_series
#'
#' Returns the hover-band events list when `use_js = TRUE`, or `NULL` when
#' `use_js = FALSE`.  Passing `NULL` omits the `point` key entirely from the
#' series options, which keeps the Highcharts tooltip intact.  Passing an
#' empty `list()` instead of `NULL` causes shared tooltips to stop working
#' because highcharter serialises it as an empty JS object that Highcharts
#' interprets as an override, suppressing default tooltip behaviour.
#'
#' @keywords internal
point_events_or_null <- function(use_js) {
  if (isTRUE(use_js)) hc_hover_band_events() else NULL
}

# ---------------------------------------------------------------------------
# line / spline
# ---------------------------------------------------------------------------

#' @keywords internal
gg_line <- function(spec, smooth = FALSE, dot_size = 4,
                    line_symbols = NULL, ...) {
  # line_symbols is highcharter-only; absorbed here to keep ... clean
  if (isTRUE(smooth)) {
    # ggplot2 has no native spline geom; use geom_smooth with loess or
    # stat_smooth. For a faithful equivalent we use geom_line + spline via
    # the `splines` stat approach via ggforce if available, otherwise plain.
    if (requireNamespace("ggforce", quietly = TRUE)) {
      ggforce::geom_bspline(linewidth = 0.8, ...)
    } else {
      ggplot2::geom_line(linewidth = 0.8, ...)
    }
  } else {
    ggplot2::geom_line(linewidth = 0.8, ...) +
      ggplot2::geom_point(size = dot_size, ...)
  }
}

#' @keywords internal
hc_line <- function(chart, spec,
                    use_js       = TRUE,
                    colors       = NULL,
                    smooth       = FALSE,
                    dot_size     = 4,
                    line_symbols = NULL,
                    ...) {

  x_index <- NULL

  group_levels <- if (!is.null(spec$group)) unique(spec$data[[spec$group]]) else NA
  palette      <- resolve_colors(length(group_levels), colors)
  symbols      <- resolve_symbols(length(group_levels), line_symbols)
  chart_type   <- if (isTRUE(smooth)) "spline" else "line"
  point_events <- point_events_or_null(use_js)

  # Build x mapping (category index for character x, raw value for numeric x)
  is_cat <- !is.numeric(spec$data[[spec$x]])
  if (is_cat) {
    x_levels          <- unique(spec$data[[spec$x]])
    spec$data$x_index <- match(spec$data[[spec$x]], x_levels) - 1L
    mapping <- highcharter::hcaes(x = x_index, y = !!rlang::sym(spec$y))
  } else {
    mapping <- highcharter::hcaes(
      x = !!rlang::sym(spec$x),
      y = !!rlang::sym(spec$y)
    )
  }

  for (i in seq_along(group_levels)) {
    grp_data <- if (!is.na(group_levels[1])) {
      spec$data[spec$data[[spec$group]] == group_levels[i], ]
    } else {
      spec$data
    }

    series_args <- list(
      chart,
      data      = grp_data,
      type      = chart_type,
      name      = as.character(group_levels[i]),
      mapping,
      color     = palette[i],
      lineWidth = 2,
      marker    = list(symbol = symbols[i], enabled = TRUE, radius = dot_size),
      states    = list(hover = list(lineWidth = 3))
    )
    # Only add `point` key when there are actual events to attach — an absent
    # key and a NULL value behave differently in Highcharts serialisation.
    if (!is.null(point_events)) series_args$point <- point_events

    chart <- do.call(highcharter::hc_add_series, c(series_args, list(...)))
  }
  chart
}

# ---------------------------------------------------------------------------
# column
# ---------------------------------------------------------------------------

#' @keywords internal
gg_column <- function(spec, smooth = FALSE, dot_size = 4,
                      line_symbols = NULL, ...) {
  # smooth / dot_size / line_symbols accepted but not used; keeps ... clean
  ggplot2::geom_col(position = "dodge", ...)
}

#' @keywords internal
hc_column <- function(chart, spec,
                      use_js       = TRUE,
                      colors       = NULL,
                      smooth       = FALSE,   # absorbed, not used
                      dot_size     = 4,       # absorbed, not used
                      line_symbols = NULL,    # absorbed, not used
                      ...) {

  x_index <- NULL

  group_levels <- if (!is.null(spec$group)) unique(spec$data[[spec$group]]) else NA
  palette      <- resolve_colors(length(group_levels), colors)
  point_events <- point_events_or_null(use_js)

  is_cat <- !is.numeric(spec$data[[spec$x]])
  if (is_cat) {
    x_levels          <- unique(spec$data[[spec$x]])
    spec$data$x_index <- match(spec$data[[spec$x]], x_levels) - 1L
    mapping <- highcharter::hcaes(x = x_index, y = !!rlang::sym(spec$y))
  } else {
    mapping <- highcharter::hcaes(
      x = !!rlang::sym(spec$x),
      y = !!rlang::sym(spec$y)
    )
  }

  for (i in seq_along(group_levels)) {
    grp_data <- if (!is.na(group_levels[1])) {
      spec$data[spec$data[[spec$group]] == group_levels[i], ]
    } else {
      spec$data
    }

    series_args <- list(
      chart,
      data   = grp_data,
      type   = "column",
      name   = as.character(group_levels[i]),
      mapping,
      color  = palette[i],
      states = list(hover = list(brightness = 0.2))
    )
    if (!is.null(point_events)) series_args$point <- point_events

    chart <- do.call(highcharter::hc_add_series, c(series_args, list(...)))
  }
  chart
}

# ---------------------------------------------------------------------------
# scatter
# ---------------------------------------------------------------------------

#' @keywords internal
gg_scatter <- function(spec, smooth = FALSE, dot_size = 4,
                       line_symbols = NULL, ...) {
  # smooth / dot_size / line_symbols accepted but not used; keeps ... clean
  ggplot2::geom_point(...)
}

#' @keywords internal
hc_scatter <- function(chart, spec,
                       use_js       = TRUE,
                       colors       = NULL,
                       smooth       = FALSE,   # absorbed, not used
                       dot_size     = 4,       # absorbed, not used
                       line_symbols = NULL,    # absorbed, not used
                       ...) {
  group_levels <- if (!is.null(spec$group)) unique(spec$data[[spec$group]]) else NA
  palette      <- resolve_colors(length(group_levels), colors)
  point_events <- point_events_or_null(use_js)

  mapping <- highcharter::hcaes(
    x = !!rlang::sym(spec$x),
    y = !!rlang::sym(spec$y)
  )

  for (i in seq_along(group_levels)) {
    grp_data <- if (!is.na(group_levels[1])) {
      spec$data[spec$data[[spec$group]] == group_levels[i], ]
    } else {
      spec$data
    }

    series_args <- list(
      chart,
      data  = grp_data,
      type  = "scatter",
      name  = as.character(group_levels[i]),
      mapping,
      color = palette[i]
    )
    if (!is.null(point_events)) series_args$point <- point_events

    chart <- do.call(highcharter::hc_add_series, c(series_args, list(...)))
  }
  chart
}

# ---------------------------------------------------------------------------
# arearange
# ---------------------------------------------------------------------------

#' @keywords internal
gg_arearange <- function(spec, ymin, ymax,
                          smooth = FALSE, dot_size = 4,
                          line_symbols = NULL, ...) {
  # smooth / dot_size / line_symbols accepted but not used; keeps ... clean
  ggplot2::geom_ribbon(
    ggplot2::aes(ymin = .data[[ymin]], ymax = .data[[ymax]]),
    alpha = 0.3,
    ...
  )
}

#' @keywords internal
hc_arearange <- function(chart, spec, ymin, ymax,
                          use_js       = TRUE,
                          colors       = NULL,
                          smooth       = FALSE,   # absorbed, not used
                          dot_size     = 4,       # absorbed, not used
                          line_symbols = NULL,    # absorbed, not used
                          ...) {
  group_levels <- if (!is.null(spec$group)) unique(spec$data[[spec$group]]) else NA
  palette      <- resolve_colors(length(group_levels), colors)
  point_events <- point_events_or_null(use_js)

  for (i in seq_along(group_levels)) {
    grp_data <- if (!is.na(group_levels[1])) {
      spec$data[spec$data[[spec$group]] == group_levels[i], ]
    } else {
      spec$data
    }

    series_args <- list(
      chart,
      data  = grp_data,
      type  = "arearange",
      name  = as.character(group_levels[i]),
      highcharter::hcaes(
        x    = !!rlang::sym(spec$x),
        low  = !!rlang::sym(ymin),
        high = !!rlang::sym(ymax)
      ),
      color = palette[i]
    )
    if (!is.null(point_events)) series_args$point <- point_events

    chart <- do.call(highcharter::hc_add_series, c(series_args, list(...)))
  }
  chart
}
