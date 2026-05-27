# Ranked bar geometry

Draws a ranked bar chart with smart label placement and optional
comparison highlighting. Bars are sorted by value, and labels are placed
inside or outside the bar depending on available space. A single
category can be highlighted with a contrasting fill colour, and an
optional horizontal line can be added to indicate a target or benchmark
value.

## Usage

``` r
hd_geom_ranked_bar(
  ascending = TRUE,
  vs = NULL,
  aim = NULL,
  char_scale = 0.045,
  min_frac = 0.08,
  ...
)
```

## Arguments

- ascending:

  Logical. If `TRUE` (default) bars are sorted in ascending order of
  `y`.

- vs:

  Character string (partial match) identifying one category to highlight
  with a contrasting fill colour. If omitted all bars use the same
  colour.

- aim:

  Numeric. Optional horizontal line indicating a target or benchmark
  value. If `NULL` (default) no line is drawn.

- char_scale:

  Numeric scaling factor that converts label character-count into
  axis-range units. Controls how generously space is estimated for each
  character. Defaults to `0.045`; increase (e.g. `0.06`0.06) for larger
  text sizes, decrease (e.g. `0.03`) for smaller ones.

- min_frac:

  Numeric. Minimum fraction of the axis range that a bar must span
  before its label is considered to fit inside. Acts as a safety floor
  for very short labels. Defaults to `0.08` (8%).

- ...:

  Geometry-specific arguments forwarded to
  [`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md).

## Value

An S3 object of class `"hd_geom"` for use with `+.hd`.

## See also

[`hd_geom_column()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_column.md),
[`hd_geom_line()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_line.md),
[`hd_geom_arearange()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_arearange.md),
[`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md),
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)

## Examples

``` r
# Regional health indicator dataset
regions <- data.frame(
  region = c("Oslo", "Viken", "Vestland", "Rogaland",
             "Trondelag", "Innlandet", "Agder",
             "Nordland", "Troms og Finnmark"),
  rate   = c(68.4, 71.2, 87.8, 10.5, 61.3, 6.1, 54.2, 49.8, 42.1),
  n      = c(402, 448, 681, 318, 297, 251, 198, 177, 148)
)

# Declarative API ----
spec_rb <- hd_spec(regions,
                  x    = "region",
                  y    = "rate",
                  n    = "n")

opts_rb <- hd_opts(
 title    = "Health indicator by region",
 subtitle = "Source: Norwegian Directorate of Health",
 ylab     = "Rate per 100 000",
 flip     = TRUE
)

hd_make(spec_rb, "ranked_bar", opts_rb, vs = "Oslo", aim = 63)

{"x":{"hc_opts":{"chart":{"reflow":true,"inverted":true},"title":{"text":"Health indicator by region"},"yAxis":{"title":{"text":null},"plotLines":[{"value":63,"color":"#7C145C","width":2,"dashStyle":"Dash","zIndex":5}]},"credits":{"enabled":false},"exporting":{"enabled":false},"boost":{"enabled":false},"plotOptions":{"series":{"label":{"enabled":false},"turboThreshold":0},"treemap":{"layoutAlgorithm":"squarified"}},"subtitle":{"text":"Source: Norwegian Directorate of Health"},"xAxis":{"categories":["Vestland","Viken","Oslo","Trondelag","Agder","Nordland","Troms og Finnmark","Rogaland","Innlandet"],"title":{"text":" "}},"tooltip":{"useHTML":true,"shared":false,"headerFormat":"","pointFormat":"<span style=\"color:{point.color}\">●<\/span> <b>{point.name}<\/b><br/>Rate per 100 000: <b>{point.y}<\/b><br/>N: <b>{point.n_obs}<\/b>"},"series":[{"type":"column","name":"Rate per 100 000","data":[{"name":"Vestland","y":87.8,"color":"#315975","n_obs":681},{"name":"Viken","y":71.2,"color":"#315975","n_obs":448},{"name":"Oslo","y":68.40000000000001,"color":"#8A294D","n_obs":402},{"name":"Trondelag","y":61.3,"color":"#315975","n_obs":297},{"name":"Agder","y":54.2,"color":"#315975","n_obs":198},{"name":"Nordland","y":49.8,"color":"#315975","n_obs":177},{"name":"Troms og Finnmark","y":42.1,"color":"#315975","n_obs":148},{"name":"Rogaland","y":10.5,"color":"#315975","n_obs":318},{"name":"Innlandet","y":6.1,"color":"#315975","n_obs":251}],"showInLegend":false,"dataLabels":{"enabled":false}}]},"theme":{"colors":["#d35400","#2980b9","#2ecc71","#f1c40f","#2c3e50","#7f8c8d"],"chart":{"style":{"fontFamily":"Roboto","color":"#666666"}},"title":{"align":"left","style":{"fontFamily":"Roboto Condensed","fontWeight":"bold"}},"subtitle":{"align":"left","style":{"fontFamily":"Roboto Condensed"}},"legend":{"align":"right","verticalAlign":"bottom"},"xAxis":{"gridLineWidth":1,"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"yAxis":{"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"plotOptions":{"line":{"marker":{"enabled":false}},"spline":{"marker":{"enabled":false}},"area":{"marker":{"enabled":false}},"areaspline":{"marker":{"enabled":false}},"arearange":{"marker":{"enabled":false}},"bubble":{"maxSize":"10%"}}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadCSV":"Download CSV","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","downloadXLS":"Download XLS","drillUpText":"◁ Back to {series.name}","exitFullscreen":"Exit from full screen","exportData":{"annotationHeader":"Annotations","categoryDatetimeHeader":"DateTime","categoryHeader":"Category"},"hideData":"Hide data table","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbolMagnitude":1000,"numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"shortWeekdays":["Sat","Sun","Mon","Tue","Wed","Thu","Fri"],"thousandsSep":" ","viewData":"View data table","viewFullscreen":"View in full screen","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"chart","fonts":["Roboto","Roboto+Condensed"],"debug":false},"evals":[],"jsHooks":[]}
# Layered API ----
hd(regions, x = "region", y = "rate", n = "n", backend = "ggplot2") +
 hd_geom_ranked_bar(
  ascending  = TRUE,
  vs         = "Oslo",
  aim        = 63,
  char_scale = 0.045,
  min_frac   = 0.08) +
 hd_opts(
 title    = "Health indicator by region",
 subtitle = "Source: Norwegian Directorate of Health",
 ylab     = "Rate per 100 000",
 flip     = TRUE
)

```
