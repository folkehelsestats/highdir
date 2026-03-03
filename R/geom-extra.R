#
# ── JS hover-band helpers ────────────────────────────────────────────────────

#' Hover-band point events (or NULL)
#'
#' When `use_js = TRUE` returns a Highcharts `point.events` list that draws a
#' translucent highlight band behind the hovered category.  When `FALSE`
#' returns `NULL` so the key is omitted entirely from the serialised config —
#' an empty `list()` would break shared tooltips.
#'
#' @param use_js    Logical.
#' @param band_color CSS colour string for the hover band.
#' @param half_width Half-width of the band in category units.
#' @keywords internal
point_events_or_null <- function(use_js,
                                  band_color = "rgba(204, 211, 255, 0.25)",
                                  half_width = 0.4) {
  if (!isTRUE(use_js)) return(NULL)
  list(events = list(
    mouseOver = htmlwidgets::JS(sprintf(
      "function(){
         var c=this.series.chart, i=this.x;
         c.xAxis[0].removePlotBand('hb');
         c.xAxis[0].addPlotBand({id:'hb',from:i-%s,to:i+%s,
           color:'%s',zIndex:0});
       }", half_width, half_width, band_color)),
    mouseOut = htmlwidgets::JS(
      "function(){ this.series.chart.xAxis[0].removePlotBand('hb'); }")
  ))
}

# ── Shared x-mapping (category index vs numeric) ────────────────────────────

#' @keywords internal
.hc_x_map <- function(spec) {
  if (!is.numeric(spec$data[[spec$x]])) {
    lvls          <- unique(spec$data[[spec$x]])
    spec$data$x_index <- match(spec$data[[spec$x]], lvls) - 1L
    list(data    = spec$data,
         mapping = highcharter::hcaes(x = x_index,
                                       y = !!rlang::sym(spec$y)))
  } else {
    list(data    = spec$data,
         mapping = highcharter::hcaes(x = !!rlang::sym(spec$x),
                                       y = !!rlang::sym(spec$y)))
  }
}

# ── Group-splitting helper ───────────────────────────────────────────────────

#' @keywords internal
.group_split <- function(spec) {
  if (!is.null(spec$group)) {
    lvls <- unique(spec$data[[spec$group]])
    lapply(lvls, function(l)
      list(name = as.character(l),
           rows = spec$data[[spec$group]] == l))
  } else {
    list(list(name = spec$y, rows = rep(TRUE, nrow(spec$data))))
  }
}

