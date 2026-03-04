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
## Highcharts draws axes in two fundamentally different ways:
## Categorical axis (e.g. "18-24", "Oslo", "Male") — Highcharts expects 0-based integer positions: 0, 1, 2, 3… and a separate categories array for the labels
## Numeric axis (e.g. 1990, 1995, 2000) — Highcharts reads the raw numbers directly as x-positions
##
## rlang::sym() converts it to a symbol and !! unquotes it so hcaes() sees y = pct rather than y = "pct"
##
## Example:
## xmap <- .hc_x_map(spec)
##
## hc_add_series(
##   data    = xmap$data[grp$rows, ],   # the (possibly modified) data frame
##   mapping = xmap$mapping             # the hcaes() with correct x reference
## )

#' @keywords internal
.hc_x_map <- function(spec) {
  if (!is.numeric(spec$data[[spec$x]])) {
    lvls          <- unique(spec$data[[spec$x]]) # Get unique group values in order of appearance i.e keep position as it's
    spec$data$x_index <- match(spec$data[[spec$x]], lvls) - 1L #provide base position to 0
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
## Draws each group when exists as a separate series
## Example:
## groups  <- .group_split(spec)
## palette <- resolve_colors(length(groups), opts$colors)
##
## for (i in seq_along(groups)) {
##   grp   <- groups[[i]]          # one descriptor
##   chart <- hc_add_series(
##     data  = data[grp$rows, ],   # only this group's rows
##     name  = grp$name,           # legend / tooltip label
##     color = palette[i]          # consistent colour per group
##   )
## }

#' @keywords internal
.group_split <- function(spec) {
  if (!is.null(spec$group)) {
    lvls <- unique(spec$data[[spec$group]]) # Get unique group values in order of appearance
    lapply(lvls, function(l)
      list(name = as.character(l),
           rows = spec$data[[spec$group]] == l))
  } else {
    list(list(name = spec$y, rows = rep(TRUE, nrow(spec$data)))) #Loop don't iterate with inner list
  }
}

