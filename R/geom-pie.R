
# ------------------------------------------------------------------------------
# PIE
# ------------------------------------------------------------------------------
# Each geometry is a pair:
#   gg_<name>  -> returns a ggplot2 layer (or list of layers)
#   hc_<name>  -> adds series to a highchart object, returns the updated chart
#
# Calling convention (enforced by the registry):
#   gg_*:  function(spec, opts, geom_params, ...)
#   hc_*:  function(chart, spec, opts, geom_params, use_js, ...)
#
# geom_params is a named list carrying all geom-specific args so that the
# engine signature stays stable as new geoms are added.  Nothing leaks into
# hc_add_series() via bare `...`.

# For a pie chart:
#   spec$x ->  slice label column
#   spec$y ->  slice value column
#   spec$group is ignored (a pie shows one series)
#
# ggplot2: geom_col() + coord_polar("y") - the classic polar-bar pie.
# highcharter: a single "pie" type series where each slice name comes from x.

#' @keywords internal
# gg_pie <- function(spec, opts, geom_params, ...) {
#   # ggplot2 pie = stacked bar in polar coordinates.
#   # We re-map: fill = x (the label column), y = y (the value column).
#   # The base canvas already has x/y mapped; we override with a coord_polar.
#   list(
#     ggplot2::aes(x = "", fill = .data[[spec$x]],
#                  y = .data[[spec$y]]),
#     ggplot2::geom_bar(stat = "identity", width = 1, colour = "white",
#                       linewidth = 0.4),
#     ggplot2::coord_polar(theta = "y"),
#     ggplot2::labs(x = NULL, y = NULL),
#     ggplot2::theme_void(),
#     ggplot2::theme(legend.position = "right")
#   )
# }


gg_pie <- function(spec, opts, geom_params, ...) {

  x_col <- spec$x
  y_col <- spec$y

  dt <- data.table::copy(spec$data)
  data.table::setDT(dt)

  # Kontroll
  if (!is.numeric(dt[[y_col]]) &&
      !is.integer(dt[[y_col]])) {
    stop(
      sprintf(
        "Pie chart requires numeric values. '%s' is not numeric.",
        y_col
      ),
      call. = FALSE
    )
  }

  total <- sum(dt[[y_col]], na.rm = TRUE)

  if (total <= 0) {
    stop(
      "Pie chart requires positive values.",
      call. = FALSE
    )
  }

  # Beregn label-posisjoner
dt$pct <- dt[[y_col]] / sum(dt[[y_col]])

dt$ypos <- cumsum(dt[[y_col]]) -
  dt[[y_col]] / 2

# Prosentetiketter
dt$label <- scales::percent(
  dt$pct,
  accuracy = 0.1
)
  p <- ggplot2::ggplot(
    dt,
    ggplot2::aes(
      x    = "",
      y    = .data[[y_col]],
      fill = .data[[x_col]]
    )
  ) +
    ggplot2::geom_col(
      width = 1,
      colour = "white",
      linewidth = 0.4
    ) +
    ggplot2::geom_text(
      ggplot2::aes(
        y = ypos,
        label = label
      ),
      colour = "white"
    ) +
    ggplot2::coord_polar(theta = "y") +
    ggplot2::labs(
      x = NULL,
      y = NULL,
      fill = x_col
    ) +
  # ggplot2::theme_void() + # Should be used after theme() to avoid overriding
    ggplot2::theme(
      legend.position = "right"
    )

 # list("__ggplot__" = p)
  return(p)
}

## # Pie is always single-series from ggplot2's perspective but uses ##
## # fill to distinguish slices — single_colour is ignored here.     ##
## gg_pie <- function(spec, opts, geom_params) {                     ##
##   list(                                                           ##
##     ggplot2::geom_bar(                                            ##
##       ggplot2::aes(x    = "",                                     ##
##                    y    = .data[[spec$y]],                        ##
##                    fill = .data[[spec$x]]),                       ##
##       stat     = "identity",                                      ##
##       width    = 1,                                               ##
##       position = "stack"                                          ##
##     ),                                                            ##
##     ggplot2::coord_polar("y", start = 0),                         ##
##     ggplot2::theme_void()                                         ##
##   )                                                               ##
## }                                                                 ##


#' @keywords internal
hc_pie <- function(chart, spec, opts, geom_params, use_js = TRUE, ...) {
    inner_size <- geom_params$inner_size %||% "0%" # "50%" = donut
    df <- spec$data
    labels <- df[[spec$x]]
    values <- df[[spec$y]]
    palette <- resolve_colors(length(labels), opts$colors)

    # Build the data list Highcharts expects for a pie series
    pie_data <- lapply(seq_len(nrow(df)), function(i) {
        list(
            name = as.character(labels[i]),
            y = values[i],
            color = palette[i]
        )
    })

    chart |>
        highcharter::hc_add_series(
            type = "pie",
            name = spec$ylab,
            data = pie_data,
            innerSize = inner_size,
            dataLabels = list(
                enabled = TRUE,
                format  = "<b>{point.name}</b>: {point.percentage:.1f}%"
            )
        )
}


# ------------------------------------------------------------------------------
# Public constructor for pie geometry layer.  See ?hd for usage.
# ------------------------------------------------------------------------------
#' Pie Geometry Layer for hd Objects
#'
#' `hd_geom_pie()` creates a pie geometry layer that is added to an [hd()]
#' object via `+`.  The layer records the geometry type and any geometry-specific
#' arguments; rendering only happens when the `hd` object is printed.
#'
#' @param inner_size A string specifying the inner radius of the pie as a percentage
#'   of the total radius.  For example, "50%" creates a donut chart
#'   with a hole in the middle.  The default "0%" creates a standard pie chart.
#'   This argument is only applicable to the Highcharts backend; it is ignored
#'   by ggplot2 since it does not support donut charts.
#' @param ... Geometry-specific arguments forwarded to [hd_make()].
#' @return An S3 object of class `"hd_geom"` for use with `+.hd`.
#'
#' @examples
#' # Category share dataset (pie)
#' drinking_freq <- data.frame(
#'     category = c("Never", "Rarely", "Monthly", "Weekly", "Daily"),
#'     pct      = c(18, 25, 30, 20, 7)
#' )
#'
#' spec_pie <- hd_spec(drinking_freq,
#'     x    = "category",
#'     y    = "pct"
#' )
#'
#' opts_pie <- hd_opts(
#'     title = "Drinking frequency",
#'     subtitle = "Source: Norwegian Directorate of Health",
#'     ylab = "Share (%)"
#' )
#'
#' # Donut interactive
#' hd_make(spec_pie, "pie", opts_pie, inner_size = "50%")
#'
#' # Composable API style (ggplot2 ignores inner_size)
#' hd(drinking_freq, x = "category", y = "pct", backend = "ggplot2") +
#'     hd_geom_pie() +
#'     hd_opts(
#'         title = "Drinking frequency",
#'         subtitle = "Source: Norwegian Directorate of Health"
#'     )
#'
#' @export
hd_geom_pie <- function(inner_size = "0%", ...) {
 hd_geom("pie", inner_size = inner_size, ...)
}
