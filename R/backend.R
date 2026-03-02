ggplot_engine <- function(spec, geom, ...) {

  p <- base_fig(spec, "ggplot2")
  p + geom$ggplot_fun(spec, ...)
}

highcharter_engine <- function(spec, geom, ...) {

  chart <- base_fig(spec, "highcharter")
  geom$highcharter_fun(chart, spec, ...)
}
