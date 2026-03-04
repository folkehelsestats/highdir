# Convert region codes to Highcharts hc-key format

Convert region codes to Highcharts hc-key format

## Usage

``` r
.to_hc_key(codes, level = c("county", "municipality"))
```

## Arguments

- codes:

  Vector of region codes.

- level:

  `"county"` or `"municipality"`.

## Value

Character vector like `"no-03"`, `"no-03-0301"`.
