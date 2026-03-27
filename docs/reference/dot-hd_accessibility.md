# Version-safe highcharter accessibility description setter

highcharter 0.9.4 does not export hc_accessibility(). This wrapper tries
the exported function first, then falls back to patching
chart\$x\$hc_opts\$accessibility directly, which works across all
highcharter versions because hc_opts is the raw Highcharts config.

## Usage

``` r
.hd_accessibility(chart, description)
```

## Arguments

- chart:

  A highchart object.

- description:

  Character. The accessibility description string.

## Value

The modified highchart object.
