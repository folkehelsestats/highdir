# Build Highcharts hover-band point events JS

Generates the `point.events.mouseOver` / `mouseOut` JavaScript that adds
a translucent highlight band behind the hovered category column. Called
from every hc\_\* series function when `use_js = TRUE`.

## Usage

``` r
hc_hover_band_events(
  band_color = "rgba(204, 211, 255, 0.25)",
  half_width = 0.4
)
```

## Arguments

- band_color:

  Character. CSS colour for the band. Default is a soft blue:
  `"rgba(204, 211, 255, 0.25)"`.

- half_width:

  Numeric. Half the band width in category units. Default `0.4` gives a
  comfortable margin around a column.

## Value

A named list suitable for `point = list(events = ...)` in
[`highcharter::hc_add_series()`](https://jkunst.com/highcharter/reference/hc_add_series.html).
