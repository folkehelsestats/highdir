# Build a Figure from a Specification

Renders a
[fig_spec](https://github.com/folkehelsestats/highdir/reference/fig_spec.md)
object using the selected backend. This is the primary function users
call after constructing a specification with
[`fig_spec()`](https://github.com/folkehelsestats/highdir/reference/fig_spec.md).

## Usage

``` r
make_fig(
  spec,
  type = "column",
  backend = "highcharter",
  use_js = TRUE,
  filename = NULL,
  smooth = TRUE,
  dot_size = 4,
  line_symbols = NULL,
  colors = NULL,
  ...
)
```

## Arguments

- spec:

  A
  [fig_spec](https://github.com/folkehelsestats/highdir/reference/fig_spec.md)
  object created by
  [`fig_spec()`](https://github.com/folkehelsestats/highdir/reference/fig_spec.md).

- type:

  Character. Geometry to use. One of the values returned by
  [`list_geoms()`](https://github.com/folkehelsestats/highdir/reference/list_geoms.md):
  `"column"`, `"line"`, `"scatter"`, `"arearange"`, or any custom
  geometry registered with
  [`register_geom()`](https://github.com/folkehelsestats/highdir/reference/register_geom.md).

- backend:

  Character. Rendering backend. One of `"highcharter"` (default,
  interactive) or `"ggplot2"` (static), or any backend registered with
  [`register_backend()`](https://github.com/folkehelsestats/highdir/reference/register_backend.md).

- use_js:

  Logical. Whether to include manually-injected JavaScript enhancements
  in the highcharter output. Tooltips, hover states, the accessibility
  module, and all other declarative Highcharts features are **always**
  included regardless of this setting. When `TRUE` (default), a
  [`htmlwidgets::JS()`](https://rdrr.io/pkg/htmlwidgets/man/JS.html)
  hover band is added behind the active category column/point via
  `point.events.mouseOver` / `mouseOut`. Set to `FALSE` to omit that
  custom callback, e.g. when you want a clean widget with no
  hand-written JS. Has no effect for the ggplot2 backend.

- filename:

  Character or `NULL`. Base filename used by the Highcharts built-in
  export menu (no extension). Defaults to `"highdir-figure"`. Ignored
  for the ggplot2 backend.

- smooth:

  Logical. For `type = "line"` only. Use spline interpolation for smooth
  curves (`TRUE`, default) or straight line segments (`FALSE`).

- dot_size:

  Numeric. For `type = "line"` only. Radius of line markers in pixels.
  Default `4`.

- line_symbols:

  Character vector or `NULL`. For `type = "line"` only. Marker symbol
  for each group. Valid values: `"circle"`, `"square"`, `"diamond"`,
  `"triangle"`, `"triangle-down"`. When `NULL` symbols are assigned
  automatically.

- colors:

  Character vector or `NULL`. Colour overrides for this figure only.
  When `NULL` the palette from
  [`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md)
  (or the hdir default palette) is used.

- ...:

  Additional arguments forwarded to the geometry's render function.
  Required arguments for a geometry (e.g. `ymin` / `ymax` for
  `"arearange"`) must be supplied here.

## Value

A `highchart` widget (when `backend = "highcharter"`) or a `ggplot`
object (when `backend = "ggplot2"`).

## See also

[`fig_spec()`](https://github.com/folkehelsestats/highdir/reference/fig_spec.md),
[`hd_save()`](https://github.com/folkehelsestats/highdir/reference/hd_save.md),
[`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md),
[`list_geoms()`](https://github.com/folkehelsestats/highdir/reference/list_geoms.md),
[`list_backends()`](https://github.com/folkehelsestats/highdir/reference/list_backends.md),
[`run_app()`](https://github.com/folkehelsestats/highdir/reference/run_app.md)

## Examples

``` r
df <- data.frame(
  age  = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
  sex  = rep(c("Male", "Female"), 4),
  pct  = c(42, 38, 55, 61, 48, 52, 60, 57),
  n    = c(120, 115, 200, 210, 180, 175, 160, 155)
)

spec <- fig_spec(
  data     = df,
  x        = "age",
  y        = "pct",
  group    = "sex",
  n        = "n",
  title    = "Health survey results",
  subtitle = "Source: Example data",
  caption  = "Tall om helse"
)
#> Error in fig_spec(data = df, x = "age", y = "pct", group = "sex", n = "n",     title = "Health survey results", subtitle = "Source: Example data",     caption = "Tall om helse"): could not find function "fig_spec"

if (FALSE) { # \dontrun{
# Interactive highcharter column chart (default)
make_fig(spec, "column")

# Same data as a smooth line chart — with JS hover effects
make_fig(spec, "line", smooth = TRUE)

# Disable JS (e.g. for self-contained HTML export)
make_fig(spec, "column", use_js = FALSE)

# Static ggplot2 version
make_fig(spec, "column", backend = "ggplot2")

# Arearange needs extra required args
spec2 <- fig_spec(df, x = "age", y = "pct", group = "sex")
make_fig(spec2, "arearange", ymin = "pct_lo", ymax = "pct_hi")
} # }
```
