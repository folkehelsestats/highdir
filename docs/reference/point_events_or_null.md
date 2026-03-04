# Hover-band point events (or NULL)

When `use_js = TRUE` returns a Highcharts `point.events` list that draws
a translucent highlight band behind the hovered category. When `FALSE`
returns `NULL` so the key is omitted entirely from the serialised config
— an empty [`list()`](https://rdrr.io/r/base/list.html) would break
shared tooltips.

## Usage

``` r
point_events_or_null(
  use_js,
  band_color = "rgba(204, 211, 255, 0.25)",
  half_width = 0.4
)
```

## Arguments

- use_js:

  Logical.

- band_color:

  CSS colour string for the hover band.

- half_width:

  Half-width of the band in category units.
