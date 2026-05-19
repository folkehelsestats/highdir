# Scatter Geometry Layer for hd Objects

`hd_geom_scatter()` creates a scatter geometry layer that is added to an
[`hd()`](https://github.com/folkehelsestats/highdir/reference/hd.md)
object via `+`. Use
[`geom_args()`](https://github.com/folkehelsestats/highdir/reference/geom_args.md)
to discover available arguments per geometry, e.g.
`geom_args("scatter")` lists `dot_size`.

## Usage

``` r
hd_geom_scatter(dot_size = 4, ...)
```

## Arguments

- dot_size:

  Numeric. Size of the points in the scatter plot. Default is 4.

- ...:

  Geometry-specific arguments forwarded to
  [`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md).
  ' @return An S3 object of class `"hd_geom"` for use with `+.hd`.

## Value

An S3 object of class `"hd_geom"` for use with `+.hd`.

## Examples

``` r
# Basic scatter plot - layered API
hd(mtcars, x = "wt", y = "mpg", backend = "ggplot2") +
 hd_geom_scatter() +
 hd_opts(title = "Scatter Plot of mtcars")


# Basic scatter plot - declarative API
car <- hd_spec(mtcars, x = "wt", y = "mpg")
opt <- hd_opts(title = "Scatter Plot of mtcars")
hd_make(car, type = "scatter")

{"x":{"hc_opts":{"chart":{"reflow":true,"inverted":false},"title":{"text":null},"yAxis":{"title":{"text":"mpg"},"labels":{"format":"{value}"},"tickInterval":10,"min":0},"credits":{"enabled":true,"text":"Helsedirektoratet","href":"https://www.helsedirektoratet.no/"},"exporting":{"enabled":true,"filename":"highdir-figure","accessibility":{"enabled":true}},"boost":{"enabled":false},"plotOptions":{"series":{"label":{"enabled":false},"turboThreshold":0},"treemap":{"layoutAlgorithm":"squarified"}},"xAxis":{"title":{"text":"wt"},"labels":{"step":1}},"subtitle":{"text":"Kilde: Navn av kilder"},"tooltip":{"useHTML":true,"shared":true,"headerFormat":"<span style=\"font-size:14px;font-weight:bold;\">{point.key}<\/span><br/>","pointFormat":"<span style=\"color:{series.color}\">●<\/span> <span style=\"color:black\">{series.name}<\/span>: <b>{point.y}<\/b><br/>"},"legend":{"align":"left","verticalAlign":"bottom","layout":"horizontal","x":50,"y":0},"series":[{"group":"group","data":[{"mpg":21,"cyl":6,"disp":160,"hp":110,"drat":3.9,"wt":2.62,"qsec":16.46,"vs":0,"am":1,"gear":4,"carb":4,"x":2.62,"y":21},{"mpg":21,"cyl":6,"disp":160,"hp":110,"drat":3.9,"wt":2.875,"qsec":17.02,"vs":0,"am":1,"gear":4,"carb":4,"x":2.875,"y":21},{"mpg":22.8,"cyl":4,"disp":108,"hp":93,"drat":3.85,"wt":2.32,"qsec":18.61,"vs":1,"am":1,"gear":4,"carb":1,"x":2.32,"y":22.8},{"mpg":21.4,"cyl":6,"disp":258,"hp":110,"drat":3.08,"wt":3.215,"qsec":19.44,"vs":1,"am":0,"gear":3,"carb":1,"x":3.215,"y":21.4},{"mpg":18.7,"cyl":8,"disp":360,"hp":175,"drat":3.15,"wt":3.44,"qsec":17.02,"vs":0,"am":0,"gear":3,"carb":2,"x":3.44,"y":18.7},{"mpg":18.1,"cyl":6,"disp":225,"hp":105,"drat":2.76,"wt":3.46,"qsec":20.22,"vs":1,"am":0,"gear":3,"carb":1,"x":3.46,"y":18.1},{"mpg":14.3,"cyl":8,"disp":360,"hp":245,"drat":3.21,"wt":3.57,"qsec":15.84,"vs":0,"am":0,"gear":3,"carb":4,"x":3.57,"y":14.3},{"mpg":24.4,"cyl":4,"disp":146.7,"hp":62,"drat":3.69,"wt":3.19,"qsec":20,"vs":1,"am":0,"gear":4,"carb":2,"x":3.19,"y":24.4},{"mpg":22.8,"cyl":4,"disp":140.8,"hp":95,"drat":3.92,"wt":3.15,"qsec":22.9,"vs":1,"am":0,"gear":4,"carb":2,"x":3.15,"y":22.8},{"mpg":19.2,"cyl":6,"disp":167.6,"hp":123,"drat":3.92,"wt":3.44,"qsec":18.3,"vs":1,"am":0,"gear":4,"carb":4,"x":3.44,"y":19.2},{"mpg":17.8,"cyl":6,"disp":167.6,"hp":123,"drat":3.92,"wt":3.44,"qsec":18.9,"vs":1,"am":0,"gear":4,"carb":4,"x":3.44,"y":17.8},{"mpg":16.4,"cyl":8,"disp":275.8,"hp":180,"drat":3.07,"wt":4.07,"qsec":17.4,"vs":0,"am":0,"gear":3,"carb":3,"x":4.07,"y":16.4},{"mpg":17.3,"cyl":8,"disp":275.8,"hp":180,"drat":3.07,"wt":3.73,"qsec":17.6,"vs":0,"am":0,"gear":3,"carb":3,"x":3.73,"y":17.3},{"mpg":15.2,"cyl":8,"disp":275.8,"hp":180,"drat":3.07,"wt":3.78,"qsec":18,"vs":0,"am":0,"gear":3,"carb":3,"x":3.78,"y":15.2},{"mpg":10.4,"cyl":8,"disp":472,"hp":205,"drat":2.93,"wt":5.25,"qsec":17.98,"vs":0,"am":0,"gear":3,"carb":4,"x":5.25,"y":10.4},{"mpg":10.4,"cyl":8,"disp":460,"hp":215,"drat":3,"wt":5.424,"qsec":17.82,"vs":0,"am":0,"gear":3,"carb":4,"x":5.424,"y":10.4},{"mpg":14.7,"cyl":8,"disp":440,"hp":230,"drat":3.23,"wt":5.345,"qsec":17.42,"vs":0,"am":0,"gear":3,"carb":4,"x":5.345,"y":14.7},{"mpg":32.4,"cyl":4,"disp":78.7,"hp":66,"drat":4.08,"wt":2.2,"qsec":19.47,"vs":1,"am":1,"gear":4,"carb":1,"x":2.2,"y":32.4},{"mpg":30.4,"cyl":4,"disp":75.7,"hp":52,"drat":4.93,"wt":1.615,"qsec":18.52,"vs":1,"am":1,"gear":4,"carb":2,"x":1.615,"y":30.4},{"mpg":33.9,"cyl":4,"disp":71.09999999999999,"hp":65,"drat":4.22,"wt":1.835,"qsec":19.9,"vs":1,"am":1,"gear":4,"carb":1,"x":1.835,"y":33.9},{"mpg":21.5,"cyl":4,"disp":120.1,"hp":97,"drat":3.7,"wt":2.465,"qsec":20.01,"vs":1,"am":0,"gear":3,"carb":1,"x":2.465,"y":21.5},{"mpg":15.5,"cyl":8,"disp":318,"hp":150,"drat":2.76,"wt":3.52,"qsec":16.87,"vs":0,"am":0,"gear":3,"carb":2,"x":3.52,"y":15.5},{"mpg":15.2,"cyl":8,"disp":304,"hp":150,"drat":3.15,"wt":3.435,"qsec":17.3,"vs":0,"am":0,"gear":3,"carb":2,"x":3.435,"y":15.2},{"mpg":13.3,"cyl":8,"disp":350,"hp":245,"drat":3.73,"wt":3.84,"qsec":15.41,"vs":0,"am":0,"gear":3,"carb":4,"x":3.84,"y":13.3},{"mpg":19.2,"cyl":8,"disp":400,"hp":175,"drat":3.08,"wt":3.845,"qsec":17.05,"vs":0,"am":0,"gear":3,"carb":2,"x":3.845,"y":19.2},{"mpg":27.3,"cyl":4,"disp":79,"hp":66,"drat":4.08,"wt":1.935,"qsec":18.9,"vs":1,"am":1,"gear":4,"carb":1,"x":1.935,"y":27.3},{"mpg":26,"cyl":4,"disp":120.3,"hp":91,"drat":4.43,"wt":2.14,"qsec":16.7,"vs":0,"am":1,"gear":5,"carb":2,"x":2.14,"y":26},{"mpg":30.4,"cyl":4,"disp":95.09999999999999,"hp":113,"drat":3.77,"wt":1.513,"qsec":16.9,"vs":1,"am":1,"gear":5,"carb":2,"x":1.513,"y":30.4},{"mpg":15.8,"cyl":8,"disp":351,"hp":264,"drat":4.22,"wt":3.17,"qsec":14.5,"vs":0,"am":1,"gear":5,"carb":4,"x":3.17,"y":15.8},{"mpg":19.7,"cyl":6,"disp":145,"hp":175,"drat":3.62,"wt":2.77,"qsec":15.5,"vs":0,"am":1,"gear":5,"carb":6,"x":2.77,"y":19.7},{"mpg":15,"cyl":8,"disp":301,"hp":335,"drat":3.54,"wt":3.57,"qsec":14.6,"vs":0,"am":1,"gear":5,"carb":8,"x":3.57,"y":15},{"mpg":21.4,"cyl":4,"disp":121,"hp":109,"drat":4.11,"wt":2.78,"qsec":18.6,"vs":1,"am":1,"gear":4,"carb":2,"x":2.78,"y":21.4}],"type":"scatter","name":"mpg","color":"#025169","point":{"events":{"mouseOver":"function(){\n         var c=this.series.chart, i=this.x;\n         c.xAxis[0].removePlotBand('hb');\n         c.xAxis[0].addPlotBand({id:'hb',from:i-0.4,to:i+0.4,\n           color:'rgba(204, 211, 255, 0.25)',zIndex:0});\n       }","mouseOut":"function(){ this.series.chart.xAxis[0].removePlotBand('hb'); }"}}}]},"theme":{"colors":["#d35400","#2980b9","#2ecc71","#f1c40f","#2c3e50","#7f8c8d"],"chart":{"style":{"fontFamily":"Roboto","color":"#666666"}},"title":{"align":"left","style":{"fontFamily":"Roboto Condensed","fontWeight":"bold"}},"subtitle":{"align":"left","style":{"fontFamily":"Roboto Condensed"}},"legend":{"align":"right","verticalAlign":"bottom"},"xAxis":{"gridLineWidth":1,"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"yAxis":{"gridLineColor":"#F3F3F3","lineColor":"#F3F3F3","minorGridLineColor":"#F3F3F3","tickColor":"#F3F3F3","tickWidth":1},"plotOptions":{"line":{"marker":{"enabled":false}},"spline":{"marker":{"enabled":false}},"area":{"marker":{"enabled":false}},"areaspline":{"marker":{"enabled":false}},"arearange":{"marker":{"enabled":false}},"bubble":{"maxSize":"10%"}}},"conf_opts":{"global":{"Date":null,"VMLRadialGradientURL":"http =//code.highcharts.com/list(version)/gfx/vml-radial-gradient.png","canvasToolsURL":"http =//code.highcharts.com/list(version)/modules/canvas-tools.js","getTimezoneOffset":null,"timezoneOffset":0,"useUTC":true},"lang":{"contextButtonTitle":"Chart context menu","decimalPoint":".","downloadCSV":"Download CSV","downloadJPEG":"Download JPEG image","downloadPDF":"Download PDF document","downloadPNG":"Download PNG image","downloadSVG":"Download SVG vector image","downloadXLS":"Download XLS","drillUpText":"◁ Back to {series.name}","exitFullscreen":"Exit from full screen","exportData":{"annotationHeader":"Annotations","categoryDatetimeHeader":"DateTime","categoryHeader":"Category"},"hideData":"Hide data table","invalidDate":null,"loading":"Loading...","months":["January","February","March","April","May","June","July","August","September","October","November","December"],"noData":"No data to display","numericSymbolMagnitude":1000,"numericSymbols":["k","M","G","T","P","E"],"printChart":"Print chart","resetZoom":"Reset zoom","resetZoomTitle":"Reset zoom level 1:1","shortMonths":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"shortWeekdays":["Sat","Sun","Mon","Tue","Wed","Thu","Fri"],"thousandsSep":" ","viewData":"View data table","viewFullscreen":"View in full screen","weekdays":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]}},"type":"chart","fonts":["Roboto","Roboto+Condensed"],"debug":false},"evals":["hc_opts.series.0.point.events.mouseOver","hc_opts.series.0.point.events.mouseOut"],"jsHooks":[]}
```
