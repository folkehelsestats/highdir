# ════════════════════════════════════════════════════════════════════════════
# AREARANGE
# ════════════════════════════════════════════════════════════════════════════
 
#' ggplot2 Arearange Geom Function
#'
#' Returns a list of ggplot2 layers (ribbon + optional centre line + points)
#' that the ggplot2 engine adds to the base figure.  Not intended to be called
#' directly; use [hd_geom_arearange()] or `hd_make(..., type = "arearange")`.
#'
#' @section geom_params recognised:
#' \describe{
#'   \item{`ymin`}{Character. **Required.** Column name for the lower bound.}
#'   \item{`ymax`}{Character. **Required.** Column name for the upper bound.}
#'   \item{`show_line`}{Logical. Draw a centre line + open-circle points on top
#'     of the ribbon.  Default `TRUE`.}
#'   \item{`single_colour`}{Character or `NULL`.  Fixed hex colour injected by
#'     the ggplot2 engine for single-series figures.  `NULL` for multi-series
#'     figures (colour is handled by [apply_gg_colors()]).}
#' }
#'
#' @param spec       An [hd_spec()] object.
#' @param opts       An [hd_opts()] object.
#' @param geom_params Named list of geom-specific arguments (see above).
#'
#' @return A list of `ggplot2` layer objects.
#'
#' @keywords internal

gg_arearange <- function(spec, opts, geom_params) {
 
  # -- Required args -----------------------------------------------------------
  ymin <- geom_params$ymin
  ymax <- geom_params$ymax
 
  if (is.null(ymin) || is.null(ymax))
    stop(
      "hd_geom_arearange() requires both `ymin` and `ymax`.\n",
      "Supply them in hd_geom_arearange(ymin = \"col_lo\", ymax = \"col_hi\").",
      call. = FALSE
    )
 
  # -- Optional args -----------------------------------------------------------
  # show_line: draw centre line + open-circle points on top of the ribbon.
  # Default TRUE to match the highcharter version.
  show_line     <- isTRUE(geom_params$show_line %||% TRUE)
 
  # single_colour: injected by the ggplot2 engine for single-series figures.
  # NULL when a group column is present (colour handled by apply_gg_colors()).
  single_colour <- geom_params$single_colour
 
  # -- Build layers ------------------------------------------------------------
  # Layer order matters: ribbon below, line + points on top (higher z-order).
 
  if (!is.null(single_colour)) {
    # Single-series: fixed colour for every layer
    layers <- list(
      ggplot2::geom_ribbon(
        ggplot2::aes(ymin = .data[[ymin]], ymax = .data[[ymax]]),
        fill  = single_colour,
        alpha = 0.25
      )
    )
    if (show_line) {
      layers <- c(layers, list(
        ggplot2::geom_line(colour = single_colour, linewidth = 0.8),
        ggplot2::geom_point(
          colour = single_colour,
          size   = 3,
          shape  = 21,
          fill   = "white",
          stroke = 1.2
        )
      ))
    }
  } else {
    # Multi-series: colour mapped via aes (resolved later by apply_gg_colors())
    layers <- list(
      ggplot2::geom_ribbon(
        ggplot2::aes(ymin = .data[[ymin]], ymax = .data[[ymax]]),
        alpha = 0.25
      )
    )
    if (show_line) {
      layers <- c(layers, list(
        ggplot2::geom_line(linewidth = 0.8),
        ggplot2::geom_point(
          size   = 3,
          shape  = 21,
          fill   = "white",
          stroke = 1.2
        )
      ))
    }
  }
 
  layers
}


# ══════════════════════════════════════════════════════════════════════════════
# hc_arearange  ── highcharter geom function
# ══════════════════════════════════════════════════════════════════════════════
 
#' Highcharter Arearange Geom Function
#'
#' Adds an arearange series (and optionally a linked centre-line series) to a
#' partially-built `highchart` object.  Not intended to be called directly; use
#' [hd_geom_arearange()] or `hd_make(..., type = "arearange")`.
#'
#' @section Series strategy:
#' For each group in `spec$data` two Highcharts series are added:
#' \enumerate{
#'   \item A `"line"` series for the centre values (`spec$y`), rendered first
#'     so it appears on top (higher z-index).  This series owns the legend
#'     entry (`showInLegend = TRUE`).
#'   \item An `"arearange"` series for the confidence band, linked back to the
#'     line series via `linkedTo = line_id`.  This means clicking the legend
#'     hides *both* line and band together.  `showInLegend = FALSE` avoids a
#'     duplicate legend entry.
#' }
#' When `show_line = FALSE` only the arearange series is added, and it owns
#' the legend entry itself.
#'
#' @section geom_params recognised:
#' \describe{
#'   \item{`ymin`}{Character. **Required.** Column name for the lower bound.}
#'   \item{`ymax`}{Character. **Required.** Column name for the upper bound.}
#'   \item{`show_line`}{Logical. Overlay the centre line.  Default `TRUE`.}
#' }
#'
#' @param chart      A `highchart` object (from [base_fig()]).
#' @param spec       An [hd_spec()] object.
#' @param opts       An [hd_opts()] object.
#' @param geom_params Named list of geom-specific arguments (see above).
#' @param use_js     Logical. Inject the hover-band JS callback.  Default `TRUE`.
#' @param ...        Unused; present for engine-contract consistency.
#'
#' @return The updated `highchart` object.
#'
#' @keywords internal
hc_arearange <- function(chart, spec, opts, geom_params,
                         use_js = TRUE, ...) {
 
  # -- Required args -----------------------------------------------------------
  ymin <- geom_params$ymin
  ymax <- geom_params$ymax
 
  if (is.null(ymin) || is.null(ymax))
    stop(
      "hd_geom_arearange() requires both `ymin` and `ymax`.\n",
      "Supply them in hd_geom_arearange(ymin = \"col_lo\", ymax = \"col_hi\").",
      call. = FALSE
    )
 
  # -- Optional args -----------------------------------------------------------
  show_line <- isTRUE(geom_params$show_line %||% TRUE)
 
  # -- Series ------------------------------------------------------------------
  groups    <- .group_split(spec)
  palette   <- resolve_colors(length(groups), opts$colors)
  point_ev  <- point_events_or_null(use_js)
 
  for (i in seq_along(groups)) {
    grp     <- groups[[i]]
    color_i <- palette[i]
 
    # Unique id per group so the arearange series can link back to its line.
    # Without a per-group id all arearanges would link to the same line.
    line_id <- paste0("line_series_", i)
 
    # ── 1. Centre-line series ─────────────────────────────────────────────────
    # Added BEFORE the arearange so Highcharts renders it on top (z-order).
    # showInLegend = TRUE: this series owns the legend entry for the group.
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
 
    # ── 2. Confidence-band (arearange) series ─────────────────────────────────
    # linkedTo ties the ribbon to the line series above so both hide/show
    # together when the user clicks the legend entry.
    # showInLegend = FALSE when show_line is TRUE (line owns the legend entry).
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

# ------------------------------------------------------------------------------
# Public geom arearange constructor
# ------------------------------------------------------------------------------

#' Add an Arearange (Confidence Band) Layer
#'
#' Geometry layer for ribbon / confidence-interval charts.  Unlike the other
#' `hd_geom_*()` functions, `ymin` and `ymax` are **required** named arguments
#' (they map to column names in `spec$data`) rather than optional `...` extras.
#' This makes the contract explicit at the call site instead of burying
#' required information inside `...`.
#'
#' @param ymin Character. Column name for the lower bound of the range.
#' @param ymax Character. Column name for the upper bound of the range.
#' @param ...  Additional optional arguments forwarded to the geom function
#'   (e.g. `show_line = FALSE`, `single_colour = "#025169"`).
#'   Run `geom_args("arearange")` for the full list.
#'
#' @return An S3 object of class `"hd_geom"` for use with `+.hd`.
#'
#' @examples
#' df <- data.frame(
#'   age  = c("18-24", "25-34", "35-44", "45-54"),
#'   pct  = c(42, 55, 48, 60),
#'   lo   = c(37, 50, 43, 55),
#'   hi   = c(47, 60, 53, 65)
#' )
#'
#' hd(df, x = "age", y = "pct") +
#'   hd_geom_arearange(ymin = "lo", ymax = "hi") +
#'   hd_opts(title = "Estimate with 95% CI", ylim = c(30, 70))
#'
#' @export
hd_geom_arearange <- function(ymin, ymax, ...) {
  hd_geom("arearange", ymin = ymin, ymax = ymax, ...)
}
