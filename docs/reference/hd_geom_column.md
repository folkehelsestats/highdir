# Column Geometry Layer for hd Objects

`hd_geom_column()` creates a column geometry layer that is added to an
[`hd()`](https://github.com/folkehelsestats/highdir/reference/hd.md)
object via `+`. The layer records the geometry type and any
geometry-specific arguments; rendering only happens when the `hd` object
is printed.

## Usage

``` r
hd_geom_column(...)
```

## Arguments

- ...:

  Geometry-specific arguments forwarded to
  [`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md).

## Value

An S3 object of class `"hd_geom"` for use with `+.hd`.

## Examples

``` r
survey <- data.frame(
  age_group = rep(c("18-24", "25-34", "35-44", "45-54", "55-64"), each = 2),
  kjonn       = rep(c("Male", "Female"), times = 5),
  pct       = c(42, 38, 55, 61, 48, 52, 60, 57, 65, 70),
  n         = c(120, 115, 200, 210, 180, 175, 160, 155, 140, 145)
)

spec_col <- hd_spec(survey,
                    x     = "age_group",
                    y     = "pct",
                    group = "kjonn",
                    n     = "n")

opts_col <- hd_opts(
  title    = "Alcohol use by age group and kjonn",
  subtitle = "Source: Norwegian Directorate of Health",
  ylim     = c(0, 100),
  yint     = 20,
  ylab     = "Percentage (%)"
)

# Interactive (default)
hd_make(spec_col, "column", opts_col)

{"x":{"hc_opts":{"chart":{"reflow":true,"inverted":false},"title":{"text":"Alcohol use by age group and kjonn"},"yAxis":{"title":{"text":"Percentage (%)"},"labels":{"format":"{value}"},"tickInterval":20,"min":0,"max":100},"credits":{"enabled":true,"text":"Helsedirektoratet","href":"https://www.helsedirektoratet.no/"},"exporting":{"enabled":true,"filename":"highdir-figure","accessibility":{"enabled":true}},"boost":{"enabled":false},"plotOptions":{"series":{"label":{"enabled":false},"turboThreshold":0},"treemap":{"layoutAlgorithm":"squarified"}},"xAxis":{"title":{"text":"age_group"},"categories":["18-24","25-34","35-44","45-54","55-64"],"tickInterval":1,"labels":{"step":1}},"subtitle":{"text":"Source: Norwegian Directorate of Health"},"tooltip":{"useHTML":true,"shared":true,"headerFormat":"<span style=\"font-size:14px;font-weight:bold;\">{point.key}<\/span><br/>","pointFormat":"<span style=\"color:{series.color}\">●<\/span> <span style=\"color:black\">{series.name}<\/span>: <b>{point.n} ({point.y})<\/b><br/>"},"legend":{"align":"left","verticalAlign":"bottom","layout":"horizontal","x":50,"y":0},"series":[{"group":"group","data":[{"age_group":"18-24","kjonn":"Male","pct":42,"n":120,"x_index":0,"x":0,"y":42},{"age_group":"25-34","kjonn":"Male","pct":55,"n":200,"x_index":1,"x":1,"y":55},{"age_group":"35-44","kjonn":"Male","pct":48,"n":180,"x_index":2,"x":2,"y":48},{"age_group":"45-54","kjonn":"Male","pct":60,"n":160,"x_index":3,"x":3,"y":60},{"age_group":"55-64","kjonn":"Male","pct":65,"n":140,"x_index":4,"x":4,"y":65}],"type":"column","name":"Male","color":"#315975","states":{"hover":{"brightness":0.2}},"point":{"events":{"mouseOver":"function(){\n         var c=this.series.chart, i=this.x;\n         c.xAxis[0].removePlotBand('hb');\n         c.xAxis[0].addPlotBand({id:'hb',from:i-0.4,to:i+0.4,\n           color:'rgba(204, 211, 255, 0.25)',zIndex:0});\n       }","mouseOut":"function(){ this.series.chart.xAxis[0].removePlotBand('hb'); }"}}},{"group":"group","data":[{"age_group":"18-24","kjonn":"Female","pct":38,"n":115,"x_index":0,"x":0,"y":38},{"age_group":"25-34","kjonn":"Female","pct":61,"n":210,"x_index":1,"x":1,"y":61},{"age_group":"35-44","kjonn":"Female","pct":52,"n":175,"x_index":2,"x":2,"y":52},{"age_group":"45-54","kjonn":"Female","pct":57,"n":155,"x_index":3,"x":3,"y":57},{"age_group":"55-64","kjonn":"Female","pct":70,"n":145,"x_index":4,"x":4,"y":70}],"type":"column","name":"Female","color":"#8A294D","states":{"hover":{"brightness":0.2}},"point":{"events":{"mouseOver":"function(){\n         var c=this.series.chart, i=this.x;\n         c.xAxis[0].removePlotBand('hb');\n         c.xAxis[0].addPlotBand({id:'hb',from:i-0.4,to:i+0.4,\n           color:'rgba(204, 211, 255, 0.25)',zIndex:0});\n       }","mouseOut":"function(){ this.series.chart.xAxis[0].removePlotBand('hb'); }"}}}]},"theme":{"colors":["#d35400","#2980b9","#2ecc71","#f1c40f","#2c3e50","#7f8c8d"],"chart":{"style":{"fontFamily":"Roboto","color":"#666666"}},"title":{"align":"left","style":{"fontFamily":"Roboto Condensed","fontWeight":"bold"}},"subtitle":{"align":"left","style":{"fontFamily":"Roboto Condensed"}},"legend":{"align":"right","verticalAlign":"bottom"},"xAxis":{"gridLineWidth":1,"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"yAxis":{"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"plotOptions":{"line":{"marker":{"enabled":false}},"spline":{"marker":{"enabled":false}},"area":{"marker":{"enabled":false}},"areaspline":{"marker":{"enabled":false}},"arearange":{"marker":{"enabled":false}},"bubble":{"maxSize":"10%"}}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadCSV":"Download CSV","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","downloadXLS":"Download XLS","drillUpText":"◁ Back to {series.name}","exitFullscreen":"Exit from full screen","exportData":{"annotationHeader":"Annotations","categoryDatetimeHeader":"DateTime","categoryHeader":"Category"},"hideData":"Hide data table","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbolMagnitude":1000,"numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"shortWeekdays":["Sat","Sun","Mon","Tue","Wed","Thu","Fri"],"thousandsSep":" ","viewData":"View data table","viewFullscreen":"View in full screen","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"chart","fonts":["Roboto","Roboto+Condensed"],"debug":false},"evals":["hc_opts.series.0.point.events.mouseOver","hc_opts.series.0.point.events.mouseOut","hc_opts.series.1.point.events.mouseOver","hc_opts.series.1.point.events.mouseOut"],"jsHooks":[]}
# Static ggplot2
hd_make(spec_col, "column", opts_col, backend = "ggplot2")
#> Scale for y is already present.
#> Adding another scale for y, which will replace the existing scale.


# Composable style
p <- hd(survey, x = "age_group", y = "pct", group = "kjonn")
p2 <- p + hd_geom_column()

# More options
p2 + hd_opts(title = "Health survey", ylim = c(0, 100))

# Pass an existing hd_spec
spec <- hd_spec(survey, x = "age_group", y = "pct", group = "kjonn", n = "n")

hd(spec, backend = "ggplot2") +
 hd_geom_column() +
 hd_opts(title = "Health survey", ylim = c(0, 80))
#> Scale for y is already present.
#> Adding another scale for y, which will replace the existing scale.

```
