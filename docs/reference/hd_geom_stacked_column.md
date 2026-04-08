# Stacked Column Geometry Layer

Create a stacked column geometry layer for `hd` objects. Each stack is a
facet (sub-panel) containing one or more series. The `stack` argument
specifies the column in the data that defines the stacks. The `group`
aesthetic in
[`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md)
defines the series within each stack. The `stacking` argument controls
how the stacks are rendered: `"normal"` (default) stacks values on top
of each other, while `"percent"` stacks values as percentages of the
total stack height.

## Usage

``` r
hd_geom_stacked_column(stack, stacking, ...)
```

## Arguments

- stack:

  Character. Column name for the stack variable. Each unique value in
  this column creates a separate stack (facet) containing all series
  with that stack value. Required.

- stacking:

  Character. Stacking mode for the column geometry. One of `"normal"`
  (default) or `"percent"`. See Highcharts documentation for details:
  https://api.highcharts.com/highcharts/plotOptions.column.stacking

- ...:

  Additional optional arguments forwarded to the geom function (e.g.
  `show_line = FALSE`, `single_colour = "#025169"`). Run
  `geom_args("arearange")` for the full list.

## Value

An S3 object of class `"hd_geom"` for use with `+.hd`.

## Examples

``` r
# Example data: sales of three products (A, B, C) across four
#' # regions (North, South, East, West)
df <- data.frame(
 region = rep(c("North", "South", "East", "West"),
              each = 3),
 product = rep(c("A", "B", "C"), times = 4),
sales   = c(10, 20, 30, 15, 25, 35, 20, 30, 40, 25, 35, 45)
)
#' # Create a stacked column chart with `region` as the stack variable and
#' # `product` as the group variable
spec <- hd_spec(df, x = "region", y = "sales", group = "product")

hd(spec) +
 hd_geom_stacked_column(stack = "region", stacking = "normal") +
hd_opts(title = "Stacked Column Chart", ylim = c(0, 120))
#> Error in hd(spec): could not find function "hd"
```
