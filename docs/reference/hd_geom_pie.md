# Pie Geometry Layer for hd Objects

`hd_geom_pie()` creates a pie geometry layer that is added to an
[`hd()`](https://github.com/folkehelsestats/highdir/reference/hd.md)
object via `+`. The layer records the geometry type and any
geometry-specific arguments; rendering only happens when the `hd` object
is printed.

## Usage

``` r
hd_geom_pie(inner_size = "0%", ...)
```

## Arguments

- inner_size:

  A string specifying the inner radius of the pie as a percentage of the
  total radius. For example, "50%" creates a donut chart with a hole in
  the middle. The default "0%" creates a standard pie chart. This
  argument is only applicable to the Highcharts backend; it is ignored
  by ggplot2 since it does not support donut charts.

- ...:

  Geometry-specific arguments forwarded to
  [`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md).

## Value

An S3 object of class `"hd_geom"` for use with `+.hd`.

## Examples

``` r
# Category share dataset (pie)
drinking_freq <- data.frame(
    category = c("Never", "Rarely", "Monthly", "Weekly", "Daily"),
    pct      = c(18, 25, 30, 20, 7)
)

spec_pie <- hd_spec(drinking_freq,
    x    = "category",
    y    = "pct"
)

opts_pie <- hd_opts(
    title = "Drinking frequency",
    subtitle = "Source: Norwegian Directorate of Health",
    ylab = "Share (%)"
)

# Donut interactive
hd_make(spec_pie, "pie", opts_pie, inner_size = "50%")

{"x":{"hc_opts":{"chart":{"reflow":true,"inverted":false},"title":{"text":"Drinking frequency"},"yAxis":{"title":{"text":"Share (%)"},"labels":{"format":"{value}"},"tickInterval":10,"min":0},"credits":{"enabled":true,"text":"Helsedirektoratet","href":"https://www.helsedirektoratet.no/"},"exporting":{"enabled":true,"filename":"highdir-figure","accessibility":{"enabled":true}},"boost":{"enabled":false},"plotOptions":{"series":{"label":{"enabled":false},"turboThreshold":0},"treemap":{"layoutAlgorithm":"squarified"}},"xAxis":{"title":{"text":"category"},"categories":["Never","Rarely","Monthly","Weekly","Daily"],"tickInterval":1,"labels":{"step":1}},"subtitle":{"text":"Source: Norwegian Directorate of Health"},"tooltip":{"useHTML":true,"shared":true,"headerFormat":"<span style=\"font-size:14px;font-weight:bold;\">{point.key}<\/span><br/>","pointFormat":"<span style=\"color:{series.color}\">●<\/span> <span style=\"color:black\">{series.name}<\/span>: <b>{point.y}<\/b><br/>"},"legend":{"align":"left","verticalAlign":"bottom","layout":"horizontal","x":50,"y":0},"series":[{"type":"pie","name":null,"data":[{"name":"Never","y":18,"color":"#025169"},{"name":"Rarely","y":25,"color":"#0069E8"},{"name":"Monthly","y":30,"color":"#7C145C"},{"name":"Weekly","y":20,"color":"#C68803"},{"name":"Daily","y":7,"color":"#047FA4"}],"innerSize":"50%","dataLabels":{"enabled":true,"format":"<b>{point.name}<\/b>: {point.percentage:.1f}%"}}]},"theme":{"colors":["#d35400","#2980b9","#2ecc71","#f1c40f","#2c3e50","#7f8c8d"],"chart":{"style":{"fontFamily":"Roboto","color":"#666666"}},"title":{"align":"left","style":{"fontFamily":"Roboto Condensed","fontWeight":"bold"}},"subtitle":{"align":"left","style":{"fontFamily":"Roboto Condensed"}},"legend":{"align":"right","verticalAlign":"bottom"},"xAxis":{"gridLineWidth":1,"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"yAxis":{"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"plotOptions":{"line":{"marker":{"enabled":false}},"spline":{"marker":{"enabled":false}},"area":{"marker":{"enabled":false}},"areaspline":{"marker":{"enabled":false}},"arearange":{"marker":{"enabled":false}},"bubble":{"maxSize":"10%"}}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadCSV":"Download CSV","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","downloadXLS":"Download XLS","drillUpText":"◁ Back to {series.name}","exitFullscreen":"Exit from full screen","exportData":{"annotationHeader":"Annotations","categoryDatetimeHeader":"DateTime","categoryHeader":"Category"},"hideData":"Hide data table","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbolMagnitude":1000,"numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"shortWeekdays":["Sat","Sun","Mon","Tue","Wed","Thu","Fri"],"thousandsSep":" ","viewData":"View data table","viewFullscreen":"View in full screen","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"chart","fonts":["Roboto","Roboto+Condensed"],"debug":false},"evals":[],"jsHooks":[]}
# Composable API style (ggplot2 ignores inner_size)
hd(drinking_freq, x = "category", y = "pct", backend = "ggplot2") +
    hd_geom_pie() +
    hd_opts(
        title = "Drinking frequency",
        subtitle = "Source: Norwegian Directorate of Health"
    )

```
