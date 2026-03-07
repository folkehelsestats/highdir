# Build a Figure from a Specification

Renders a
[hd_spec](https://github.com/folkehelsestats/highdir/reference/hd_spec.md)
and
[hd_opts](https://github.com/folkehelsestats/highdir/reference/hd_opts.md)
pair using the selected backend and geometry. This is the central
function of the package — everything else feeds into or flows out of
`hd_make()`.

## Usage

``` r
hd_make(
  spec,
  type = "column",
  opts = NULL,
  backend = "highcharter",
  use_js = TRUE,
  module = TRUE,
  filename = NULL,
  smooth = TRUE,
  dot_size = 4,
  line_symbols = NULL,
  inner_size = "0%",
  level = "county",
  value_lab = NULL,
  na_fill = "#D3D3D3",
  low_col = "#C6DBEF",
  high_col = "#025169",
  ...
)
```

## Arguments

- spec:

  A
  [hd_spec](https://github.com/folkehelsestats/highdir/reference/hd_spec.md)
  object from
  [`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md).

- type:

  Character. Geometry name — one of
  [`list_geoms()`](https://github.com/folkehelsestats/highdir/reference/list_geoms.md):
  `"column"`, `"line"`, `"scatter"`, `"arearange"`, `"pie"`, or any
  custom geometry added with
  [`register_geom()`](https://github.com/folkehelsestats/highdir/reference/register_geom.md).

- opts:

  A
  [hd_opts](https://github.com/folkehelsestats/highdir/reference/hd_opts.md)
  object or `NULL` (uses all defaults). Controls title, subtitle,
  caption, ylim, yint, flip, per-figure colours, and highcharter theme.

- backend:

  Character. Rendering engine — `"highcharter"` (default, interactive)
  or `"ggplot2"` (static), or any engine added with
  [`register_backend()`](https://github.com/folkehelsestats/highdir/reference/register_backend.md).

- use_js:

  Logical. When `TRUE` (default) injects a hover-band
  [`htmlwidgets::JS()`](https://rdrr.io/pkg/htmlwidgets/man/JS.html)
  callback via `point.events.mouseOver/Out`. Tooltips, accessibility
  module, and all other Highcharts declarative features are **always**
  present. Set `FALSE` for clean, no-custom-JS widgets. Ignored by the
  ggplot2 backend.

- module:

  Use available modules js from CDN
  <https://api.highcharts.com/highcharts>

- filename:

  Character or `NULL`. Base filename for the Highcharts export menu (no
  extension). Default: `"highdir-figure"`.

- smooth:

  Logical. `type = "line"` only — spline curves (`TRUE`, default) or
  straight segments (`FALSE`).

- dot_size:

  Numeric. `type = "line"` / `"scatter"` — marker radius in pixels.
  Default `4`.

- line_symbols:

  Character vector or `NULL`. `type = "line"` only — per-group
  Highcharts marker symbols. Valid: `"circle"`, `"square"`, `"diamond"`,
  `"triangle"`, `"triangle-down"`.

- inner_size:

  Character or `NULL`. `type = "pie"` only — inner radius as a CSS
  percentage string, e.g. `"50%"` for a donut chart. Default `"0%"`
  (solid pie).

- level:

  Character. `type = "map"` only — `"county"` (default) for fylker or
  `"municipality"` for kommuner.

- value_lab:

  Character or `NULL`. `type = "map"` only — label shown on the
  colour-scale legend. Defaults to `spec$ylab`.

- na_fill:

  Character. `type = "map"` only — fill colour for regions with no data.
  Default `"#D3D3D3"`.

- low_col:

  Character. `type = "map"`, ggplot2 backend — low end of the continuous
  gradient. Default `"#C6DBEF"`.

- high_col:

  Character. `type = "map"`, ggplot2 backend — high end of the
  continuous gradient. Default `"#025169"`.

- ...:

  Extra arguments forwarded to the geometry function. Required arguments
  (e.g. `ymin`, `ymax` for `"arearange"`) **must** be supplied here.

## Value

A `highchart` widget (highcharter backend) or `ggplot` object (ggplot2
backend), invisibly wrapped so knitr/Shiny render it automatically.

## Workflow

    spec <- hd_spec(df, x = "age", y = "pct", group = "sex", n = "n")
    opts <- hd_opts(title = "Health survey", ylim = c(0, 80))

    hd_make(spec, "column", opts)                       # highcharter (default)
    hd_make(spec, "column", opts, backend = "ggplot2")  # static ggplot2
    hd_make(spec, "line",   opts, smooth = TRUE)        # smooth spline
    hd_make(spec, "pie",    opts)                       # pie / donut

## See also

[`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md),
[`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md),
[`hd_save()`](https://github.com/folkehelsestats/highdir/reference/hd_save.md),
[`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md),
[`list_geoms()`](https://github.com/folkehelsestats/highdir/reference/list_geoms.md),
[`list_backends()`](https://github.com/folkehelsestats/highdir/reference/list_backends.md),
[`hd_app()`](https://github.com/folkehelsestats/highdir/reference/hd_app.md)

## Examples

``` r
df <- data.frame(
  age = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
  sex = rep(c("Male", "Female"), 4),
  pct = c(42, 38, 55, 61, 48, 52, 60, 57),
  n   = c(120, 115, 200, 210, 180, 175, 160, 155)
)

spec <- hd_spec(df, x = "age", y = "pct", group = "sex", n = "n")

opts <- hd_opts(title    = "Health survey results",
                 subtitle = "Source: FHI 2024",
                 ylim     = c(0, 80))

if (FALSE) { # \dontrun{
# ── Interactive charts (highcharter) ──────────────────────────────────────
hd_make(spec, "column", opts)
hd_make(spec, "line",   opts, smooth = TRUE)
hd_make(spec, "line",   opts, smooth = FALSE, dot_size = 6)
hd_make(spec, "scatter")

# Pie chart — group is ignored; x = label, y = value
pie_df   <- data.frame(category = c("A","B","C","D"),
                        value    = c(35, 25, 20, 20))
pie_spec <- hd_spec(pie_df, x = "category", y = "value")
pie_opts <- hd_opts(title = "Share by category")
hd_make(pie_spec, "pie", pie_opts)
hd_make(pie_spec, "pie", pie_opts, inner_size = "50%")  # donut

# Arearange — requires ymin + ymax in ...
df2   <- cbind(df, lo = df$pct - 5, hi = df$pct + 5)
spec2 <- hd_spec(df2, "age", "pct", group = "sex")
hd_make(spec2, "arearange", opts, ymin = "lo", ymax = "hi")

# ── Disable JS hover band ─────────────────────────────────────────────────
hd_make(spec, "column", opts, use_js = FALSE)

# ── Static ggplot2 versions ───────────────────────────────────────────────
hd_make(spec, "column",  opts, backend = "ggplot2")
hd_make(spec, "line",    opts, backend = "ggplot2")
hd_make(spec, "scatter", opts, backend = "ggplot2")
hd_make(pie_spec, "pie", pie_opts, backend = "ggplot2")

# ── Reuse spec with different presentation ────────────────────────────────
opts_no <- hd_opts(title = "Helseundersøkelse", subtitle = "Alle aldre")
hd_make(spec, "column", opts_no)

# ── Save outputs ──────────────────────────────────────────────────────────
hd_save(hd_make(spec, "column", opts),               "column.html")
hd_save(hd_make(spec, "column", opts, backend="ggplot2"), "column.png")
} # }
```
