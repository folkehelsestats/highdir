# Create a Figure Data Specification

Defines the **data mapping** for a figure - which columns map to x, y,
group, and count - independently of any visual presentation choices.
Pass the result to
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)
together with an optional
[`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md)
object.

## Usage

``` r
hd_spec(data, x, y, group = NULL, n = NULL, colour = NULL)
```

## Arguments

- data:

  A `data.frame` containing all referenced columns.

- x:

  Character. Column name for the x-axis variable.

- y:

  Character. Column name for the y-axis variable (typically a percentage
  or count).

- group:

  Character or `NULL`. Column used to split data into multiple series.

- n:

  Character or `NULL`. Column of raw counts shown in highcharter
  tooltips alongside the y value. Ignored by ggplot2.

- colour:

  Character or `NULL`. ggplot2 colour aesthetic column. Defaults to
  `group` when `NULL` and `group` is set.

## Value

An S3 object of class `"hd_spec"`.

## See also

[`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md),
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)

## Examples

``` r
df <- data.frame(
  age = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
  sex = rep(c("Male", "Female"), 4),
  pct = c(42, 38, 55, 61, 48, 52, 60, 57),
  n   = c(120, 115, 200, 210, 180, 175, 160, 155)
)

spec <- hd_spec(df, x = "age", y = "pct", group = "sex", n = "n")
spec
#> <hd_spec>
#>   data   : df 
#>   x      : age 
#>   y      : pct 
#>   group  : sex 
#>   n      : n 
#>   rows   : 8 
```
