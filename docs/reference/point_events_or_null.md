# Resolve point-events argument for hc_add_series

Returns the hover-band events list when `use_js = TRUE`, or `NULL` when
`use_js = FALSE`. Passing `NULL` omits the `point` key entirely from the
series options, which keeps the Highcharts tooltip intact. Passing an
empty [`list()`](https://rdrr.io/r/base/list.html) instead of `NULL`
causes shared tooltips to stop working because highcharter serialises it
as an empty JS object that Highcharts interprets as an override,
suppressing default tooltip behaviour.

## Usage

``` r
point_events_or_null(use_js)
```
