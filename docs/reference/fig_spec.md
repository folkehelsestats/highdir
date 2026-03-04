# Create a Figure Specification

Defines a backend-agnostic description of a figure. Pass the returned
object to
[`make_fig()`](https://github.com/folkehelsestats/highdir/reference/make_fig.md)
to render it with either `"highcharter"` or `"ggplot2"`.

## Usage

``` r
fig_spec(
  data,
  x,
  y,
  group = NULL,
  n = NULL,
  colour = NULL,
  xlab = NULL,
  ylab = NULL,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  ylim = NULL,
  yint = 10,
  flip = FALSE
)
```

## Arguments

- data:

  A `data.frame` (or `data.table`) containing all referenced columns.

- x:

  Character. Column name for the x-axis variable.

- y:

  Character. Column name for the y-axis variable (typically a percentage
  or count).

- group:

  Character or `NULL`. Column name used to split the data into multiple
  series / groups.

- n:

  Character or `NULL`. Column name of a raw count variable shown in
  highcharter tooltips alongside the y value. Ignored for ggplot2.

- colour:

  Character or `NULL`. Column name mapped to the colour aesthetic
  (ggplot2 only; highcharter uses `group` for colouring).

- xlab:

  Character or `NULL`. X-axis label. Defaults to `x` when `NULL`.

- ylab:

  Character or `NULL`. Y-axis label. Defaults to `y` when `NULL`.

- title:

  Character or `NULL`. Chart title.

- subtitle:

  Character or `NULL`. Chart subtitle. Defaults to
  `"Kilde: Navn av kilder"` in the highcharter engine when `NULL`.

- caption:

  Character or `NULL`. Caption text shown below the chart (highcharter
  only).

- ylim:

  Numeric vector of length 2 or `NULL`. Fixed y-axis limits, e.g.
  `c(0, 100)`. `NULL` lets the backend determine limits automatically.

- yint:

  Numeric. Y-axis tick interval. Default `10`.

- flip:

  Logical. Invert axes (horizontal bars). Default `FALSE`.

## Value

An object of S3 class `fig_spec`.

## Examples

``` r
df <- data.frame(
  age   = rep(c("18-24", "25-34", "35-44"), each = 2),
  sex   = rep(c("Male", "Female"), 3),
  pct   = c(42, 38, 55, 61, 48, 52),
  n     = c(120, 115, 200, 210, 180, 175)
)

spec <- fig_spec(
  data     = df,
  x        = "age",
  y        = "pct",
  group    = "sex",
  n        = "n",
  title    = "Health survey results",
  subtitle = "Source: Example data"
)
#> Error in fig_spec(data = df, x = "age", y = "pct", group = "sex", n = "n",     title = "Health survey results", subtitle = "Source: Example data"): could not find function "fig_spec"
spec
#> Error: object 'spec' not found
```
