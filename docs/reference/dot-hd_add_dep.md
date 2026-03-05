# Version-safe hc_add_dependency wrapper

highcharter 0.9.4 takes the path as a positional argument. Older
versions used name = . This wrapper handles both.

## Usage

``` r
.hd_add_dep(chart, path)
```
