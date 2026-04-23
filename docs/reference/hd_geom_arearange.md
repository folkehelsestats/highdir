# Add an Arearange (Confidence Band) Layer

Geometry layer for ribbon / confidence-interval charts. Unlike the other
`hd_geom_*()` functions, `ymin` and `ymax` are **required** named
arguments (they map to column names in `spec$data`) rather than optional
`...` extras. This makes the contract explicit at the call site instead
of burying required information inside `...`.

## Usage

``` r
hd_geom_arearange(ymin, ymax, ...)
```

## Arguments

- ymin:

  Character. Column name for the lower bound of the range.

- ymax:

  Character. Column name for the upper bound of the range.

- ...:

  Additional optional arguments forwarded to the geom function (e.g.
  `show_line = FALSE`, `single_colour = "#025169"`). Run
  `geom_args("arearange")` for the full list.

## Value

An S3 object of class `"hd_geom"` for use with `+.hd`.

## Examples

``` r
df <- data.frame(
  age  = c("18-24", "25-34", "35-44", "45-54"),
  pct  = c(42, 55, 48, 60),
  lo   = c(37, 50, 43, 55),
  hi   = c(47, 60, 53, 65)
)

hd(df, x = "age", y = "pct") +
  hd_geom_arearange(ymin = "lo", ymax = "hi") +
  hd_opts(title = "Estimate with 95% CI", ylim = c(30, 70))

hd(df, x = "age", y = "pct", backend = "ggplot2") +
  hd_geom_arearange(ymin = "lo", ymax = "hi") +
  hd_opts(title = "Estimate with 95% CI", ylim = c(30, 70))
#> Scale for y is already present.
#> Adding another scale for y, which will replace the existing scale.
#> `geom_line()`: Each group consists of only one observation.
#> ℹ Do you need to adjust the group aesthetic?

```
