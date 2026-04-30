# Line Geometry Layer for hd Objects

`hd_geom_line()` creates a line geometry layer that is added to an
[`hd()`](https://github.com/folkehelsestats/highdir/reference/hd.md)
object via `+`. The layer records the geometry type and any
geometry-specific arguments; rendering only happens when the `hd` object
is printed.

## Usage

``` r
hd_geom_line(smooth, dot_size, line_symbols, ...)
```

## Arguments

- smooth:

  Logical. TRUE = spline curves, FALSE = straight segments. Both
  backends.

- dot_size:

  Numeric. Marker radius in pixels. Both backends.

- line_symbols:

  Character vector. Highcharter only. Per-group marker shapes: "circle",
  "square", "diamond", "triangle", "triangle-down".

- ...:

  Geometry-specific arguments forwarded to
  [`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md).

## Value

An S3 object of class `"hd_geom"` for use with `+.hd`.

## Examples

``` r
# Single series - no group column
spec_line1 <- hd_spec(alco1,
    x    = "year",
    y    = "adj_mean"
)

opts_line <- hd_opts(
    title = "Alcohol consumption over time",
    subtitle = "Source: Norwegian Directorate of Health",
    ylim = c(0, 50),
    ylab = "Litres per capita"
)


# Straight segments
hd_make(spec_line1, "line", opts_line, smooth = FALSE)

{"x":{"hc_opts":{"chart":{"reflow":true,"inverted":false},"title":{"text":"Alcohol consumption over time"},"yAxis":{"title":{"text":"Litres per capita"},"labels":{"format":"{value}"},"tickInterval":10,"min":0,"max":50},"credits":{"enabled":true,"text":"Helsedirektoratet","href":"https://www.helsedirektoratet.no/"},"exporting":{"enabled":true,"filename":"highdir-figure","accessibility":{"enabled":true}},"boost":{"enabled":false},"plotOptions":{"series":{"label":{"enabled":false},"turboThreshold":0},"treemap":{"layoutAlgorithm":"squarified"}},"xAxis":{"title":{"text":"year"},"labels":{"step":1}},"subtitle":{"text":"Source: Norwegian Directorate of Health"},"tooltip":{"useHTML":true,"shared":true,"headerFormat":"<span style=\"font-size:14px;font-weight:bold;\">{point.key}<\/span><br/>","pointFormat":"<span style=\"color:{series.color}\">●<\/span> <span style=\"color:black\">{series.name}<\/span>: <b>{point.y}<\/b><br/>"},"legend":{"align":"left","verticalAlign":"bottom","layout":"horizontal","x":50,"y":0},"series":[{"group":"group","data":[{"year":2012,"adj_mean":29.5688209339651,"SE":1.31401820814255,"lower_95CI":26.991788087279,"upper_95CI":32.1458537806512,"adj_enhet":19.7,"SE_enhet":0.9,"lower_enhet":18,"upper_enhet":21.4,"x":2012,"y":29.5688209339651},{"year":2013,"adj_mean":26.3820822909097,"SE":0.898223842915541,"lower_95CI":24.6205796839981,"upper_95CI":28.1435848978212,"adj_enhet":17.6,"SE_enhet":0.6,"lower_enhet":16.4,"upper_enhet":18.8,"x":2013,"y":26.3820822909097},{"year":2014,"adj_mean":30.2479196947083,"SE":1.22017849767529,"lower_95CI":27.8550502174718,"upper_95CI":32.6407891719448,"adj_enhet":20.2,"SE_enhet":0.8,"lower_enhet":18.6,"upper_enhet":21.8,"x":2014,"y":30.2479196947083},{"year":2015,"adj_mean":24.9407936417249,"SE":0.957939144175014,"lower_95CI":23.0622482786227,"upper_95CI":26.819339004827,"adj_enhet":16.6,"SE_enhet":0.6,"lower_enhet":15.4,"upper_enhet":17.9,"x":2015,"y":24.9407936417249},{"year":2016,"adj_mean":25.1552075711597,"SE":1.07138968311867,"lower_95CI":23.0540848610285,"upper_95CI":27.2563302812909,"adj_enhet":16.8,"SE_enhet":0.7,"lower_enhet":15.4,"upper_enhet":18.2,"x":2016,"y":25.1552075711597},{"year":2017,"adj_mean":27.7067665662493,"SE":0.953327936942322,"lower_95CI":25.837246795542,"upper_95CI":29.5762863369565,"adj_enhet":18.5,"SE_enhet":0.6,"lower_enhet":17.2,"upper_enhet":19.7,"x":2017,"y":27.7067665662493},{"year":2018,"adj_mean":26.6906409447571,"SE":1.04394544742553,"lower_95CI":24.6434098689602,"upper_95CI":28.737872020554,"adj_enhet":17.8,"SE_enhet":0.7,"lower_enhet":16.4,"upper_enhet":19.2,"x":2018,"y":26.6906409447571},{"year":2019,"adj_mean":25.4251533588897,"SE":0.982999807380581,"lower_95CI":23.4974198595009,"upper_95CI":27.3528868582785,"adj_enhet":17,"SE_enhet":0.7,"lower_enhet":15.7,"upper_enhet":18.2,"x":2019,"y":25.4251533588897},{"year":2020,"adj_mean":22.5086285695819,"SE":0.964926259096375,"lower_95CI":20.6163601352583,"upper_95CI":24.4008970039054,"adj_enhet":15,"SE_enhet":0.6,"lower_enhet":13.7,"upper_enhet":16.3,"x":2020,"y":22.5086285695819},{"year":2021,"adj_mean":25.7139807039743,"SE":1.06360056066082,"lower_95CI":23.62820174148,"upper_95CI":27.7997596664686,"adj_enhet":17.1,"SE_enhet":0.7,"lower_enhet":15.8,"upper_enhet":18.5,"x":2021,"y":25.7139807039743},{"year":2022,"adj_mean":26.9308848055767,"SE":1.0789167751084,"lower_95CI":24.8149252900896,"upper_95CI":29.0468443210639,"adj_enhet":18,"SE_enhet":0.7,"lower_enhet":16.5,"upper_enhet":19.4,"x":2022,"y":26.9308848055767},{"year":2023,"adj_mean":26.2342670110855,"SE":1.04762055989223,"lower_95CI":24.1797904994535,"upper_95CI":28.2887435227175,"adj_enhet":17.5,"SE_enhet":0.7,"lower_enhet":16.1,"upper_enhet":18.9,"x":2023,"y":26.2342670110855},{"year":2024,"adj_mean":27.3435961548172,"SE":0.738525586449375,"lower_95CI":25.8957573623531,"upper_95CI":28.7914349472813,"adj_enhet":18.2,"SE_enhet":0.5,"lower_enhet":17.3,"upper_enhet":19.2,"x":2024,"y":27.3435961548172},{"year":2025,"adj_mean":26.1531628575368,"SE":0.807543719380914,"lower_95CI":24.569989140382,"upper_95CI":27.7363365746917,"adj_enhet":17.4,"SE_enhet":0.5,"lower_enhet":16.4,"upper_enhet":18.5,"x":2025,"y":26.1531628575368}],"type":"line","name":"adj_mean","color":"#025169","lineWidth":2,"marker":{"symbol":"circle","enabled":true,"radius":4},"states":{"hover":{"lineWidth":3}},"point":{"events":{"mouseOver":"function(){\n         var c=this.series.chart, i=this.x;\n         c.xAxis[0].removePlotBand('hb');\n         c.xAxis[0].addPlotBand({id:'hb',from:i-0.4,to:i+0.4,\n           color:'rgba(204, 211, 255, 0.25)',zIndex:0});\n       }","mouseOut":"function(){ this.series.chart.xAxis[0].removePlotBand('hb'); }"}}}]},"theme":{"colors":["#d35400","#2980b9","#2ecc71","#f1c40f","#2c3e50","#7f8c8d"],"chart":{"style":{"fontFamily":"Roboto","color":"#666666"}},"title":{"align":"left","style":{"fontFamily":"Roboto Condensed","fontWeight":"bold"}},"subtitle":{"align":"left","style":{"fontFamily":"Roboto Condensed"}},"legend":{"align":"right","verticalAlign":"bottom"},"xAxis":{"gridLineWidth":1,"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"yAxis":{"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"plotOptions":{"line":{"marker":{"enabled":false}},"spline":{"marker":{"enabled":false}},"area":{"marker":{"enabled":false}},"areaspline":{"marker":{"enabled":false}},"arearange":{"marker":{"enabled":false}},"bubble":{"maxSize":"10%"}}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadCSV":"Download CSV","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","downloadXLS":"Download XLS","drillUpText":"◁ Back to {series.name}","exitFullscreen":"Exit from full screen","exportData":{"annotationHeader":"Annotations","categoryDatetimeHeader":"DateTime","categoryHeader":"Category"},"hideData":"Hide data table","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbolMagnitude":1000,"numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"shortWeekdays":["Sat","Sun","Mon","Tue","Wed","Thu","Fri"],"thousandsSep":" ","viewData":"View data table","viewFullscreen":"View in full screen","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"chart","fonts":["Roboto","Roboto+Condensed"],"debug":false},"evals":["hc_opts.series.0.point.events.mouseOver","hc_opts.series.0.point.events.mouseOut"],"jsHooks":[]}
# Composite example with multiple geoms and custom line symbols
hd(alco2, x = "year", y = "adj_mean", group = "kjonn", backend = "ggplot2") +
  hd_geom_line(smooth = TRUE, dot_size = 3) +
  hd_opts(title = "Alcohol consumption over time by kjonn", subtitle = "Source: Norwegian Directorate of Health")

```
