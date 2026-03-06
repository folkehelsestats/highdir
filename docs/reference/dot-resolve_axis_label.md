# Resolve an axis label from opts and spec

Three-way logic: NULL → hide the axis label entirely " " → use the
column name from spec as the fallback string → use the string as-is

## Usage

``` r
.resolve_axis_label(opts_label, spec_col)
```

## Arguments

- opts_label:

  The value from hd_opts()\$ylab or \$xlab.

- spec_col:

  The column name from hd_spec()\$y or \$x.

## Value

Character string or NULL.
