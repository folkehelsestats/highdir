# Stacked Column Geometry Layer

Create a stacked column geometry layer for `hd` objects. Each stack is a
facet (sub-panel) containing one or more series. The `stack` argument
specifies the column in the data that defines the stacks. The `group`
aesthetic in
[`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md)
defines the series within each stack. The `stacking` argument controls
how the stacks are rendered: `"normal"` (default) stacks values on top
of each other, while `"percent"` stacks values as percentages of the
total stack height.

## Usage

``` r
hd_geom_stacked_column(stack, stacking = c("normal", "percent"), ...)
```

## Arguments

- stack:

  Character. Column name for the stack variable. Each unique value in
  this column creates a separate stack (facet) containing all series
  with that stack value. Required.

- stacking:

  Character. Stacking mode for the column geometry. One of `"normal"`
  (default) or `"percent"`. See Highcharts documentation for details:
  https://api.highcharts.com/highcharts/plotOptions.column.stacking

- ...:

  Additional optional arguments forwarded to the geom function (e.g.
  `show_line = FALSE`, `single_colour = "#025169"`). Run
  `geom_args("arearange")` for the full list.

## Value

An S3 object of class `"hd_geom"` for use with `+.hd`.

## Examples

``` r
# Example data: medal counts for four countries across three medal types
olympics <- data.frame(
    Country   = rep(c("Norway", "Germany", "United States", "Canada"), each = 3),
    Continent = rep(c("Europe", "Europe", "North America", "North America"), each = 3),
    Medal     = rep(c("Gold", "Silver", "Bronze"), times = 4),
    Count     = c(148, 133, 124, 102, 98, 65, 113, 122, 95, 77, 72, 80)
)

# Define Specification and Options
spec_st <- hd_spec(olympics,
    x     = "Medal",
    y     = "Count",
    group = "Country"
)

opts_st <- hd_opts(
    title    = "Olympic Games all-time medal table, grouped by continent",
    subtitle = "Source: Olympics",
    ylab     = "Count medals"
)

# Interactive — stacks are separated by continent
hd_make(spec_st, "stacked_column", opts_st, stack = "Continent")

{"x":{"hc_opts":{"chart":{"reflow":true,"inverted":false},"title":{"text":"Olympic Games all-time medal table, grouped by continent"},"yAxis":{"title":{"text":"Count medals"},"labels":{"format":"{value}"},"tickInterval":10,"min":0},"credits":{"enabled":true,"text":"Helsedirektoratet","href":"https://www.helsedirektoratet.no/"},"exporting":{"enabled":true,"filename":"highdir-figure","accessibility":{"enabled":true}},"boost":{"enabled":false},"plotOptions":{"series":{"label":{"enabled":false},"turboThreshold":0},"treemap":{"layoutAlgorithm":"squarified"},"column":{"stacking":"normal"}},"xAxis":{"title":{"text":"Medal"},"categories":["Gold","Silver","Bronze"],"tickInterval":1,"labels":{"step":1}},"subtitle":{"text":"Source: Olympics"},"tooltip":{"useHTML":true,"shared":true,"headerFormat":"<span style=\"font-size:14px;font-weight:bold;\">{point.key}<\/span><br/>","pointFormat":"<span style=\"color:{series.color}\">●<\/span> <span style=\"color:black\">{series.name}<\/span>: <b>{point.y}<\/b><br/>"},"legend":{"align":"left","verticalAlign":"bottom","layout":"horizontal","x":50,"y":0},"series":[{"name":"Norway","type":"column","data":[148,133,124],"stack":"Europe","color":"#025169","showInLegend":true},{"name":"Germany","type":"column","data":[102,98,65],"stack":"Europe","color":"#0069E8","showInLegend":true},{"name":"United States","type":"column","data":[113,122,95],"stack":"North America","color":"#7C145C","showInLegend":true},{"name":"Canada","type":"column","data":[77,72,80],"stack":"North America","color":"#C68803","showInLegend":true}]},"theme":{"colors":["#d35400","#2980b9","#2ecc71","#f1c40f","#2c3e50","#7f8c8d"],"chart":{"style":{"fontFamily":"Roboto","color":"#666666"}},"title":{"align":"left","style":{"fontFamily":"Roboto Condensed","fontWeight":"bold"}},"subtitle":{"align":"left","style":{"fontFamily":"Roboto Condensed"}},"legend":{"align":"right","verticalAlign":"bottom"},"xAxis":{"gridLineWidth":1,"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"yAxis":{"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"plotOptions":{"line":{"marker":{"enabled":false}},"spline":{"marker":{"enabled":false}},"area":{"marker":{"enabled":false}},"areaspline":{"marker":{"enabled":false}},"arearange":{"marker":{"enabled":false}},"bubble":{"maxSize":"10%"}}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadCSV":"Download CSV","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","downloadXLS":"Download XLS","drillUpText":"◁ Back to {series.name}","exitFullscreen":"Exit from full screen","exportData":{"annotationHeader":"Annotations","categoryDatetimeHeader":"DateTime","categoryHeader":"Category"},"hideData":"Hide data table","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbolMagnitude":1000,"numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"shortWeekdays":["Sat","Sun","Mon","Tue","Wed","Thu","Fri"],"thousandsSep":" ","viewData":"View data table","viewFullscreen":"View in full screen","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"chart","fonts":["Roboto","Roboto+Condensed"],"debug":false},"evals":[],"jsHooks":[]}
# Static ggplot2 — stacks are separated by continent
hd(spec_st, backend = "ggplot2") +
  hd_geom_stacked_column(stack = "Continent") +
  hd_opts(title = "Olympic Games all-time medal table, grouped by continent", ylab = "Count medals")

```
