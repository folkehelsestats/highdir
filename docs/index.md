# highdir

**highdir** is an R package that provides a unified, backend-agnostic
API for building figures with either
[**highcharter**](https://jkunst.com/highcharter/) (interactive) or
[**ggplot2**](https://ggplot2.tidyverse.org/) (static).

A figure is described once as a `fig_spec` object and rendered to either
backend without changing the calling code. The package ships with the
default to use Helsedirektoratet colour palette, styling and theme. A
Shiny GUI is introduce to make it user friendly.

------------------------------------------------------------------------

## Installation

``` r
# Install from GitHub (dev branch)
remotes::install_github("folkehelsestats/highdir@dev")
```

------------------------------------------------------------------------

## Quick start

``` r
library(highdir)

df <- data.frame(
  age  = rep(c("18-24", "25-34", "35-44", "45-54"), each = 2),
  sex  = rep(c("Male", "Female"), 4),
  pct  = c(42, 38, 55, 61, 48, 52, 60, 57),
  n    = c(120, 115, 200, 210, 180, 175, 160, 155)
)

# 1. Describe the figure once
spec <- fig_spec(
  data     = df,
  x        = "age",
  y        = "pct",
  group    = "sex",
  n        = "n",            # shown in highcharter tooltips
  title    = "Health survey results",
  subtitle = "Source: Example data",
  caption  = "Tall om helse"
)

# 2. Render to highcharter (interactive, default)
make_fig(spec, "column")

# 3. Same spec → ggplot2 (static)
make_fig(spec, "column", backend = "ggplot2")

# 4. Line chart with smooth spline and hover band
make_fig(spec, "line", smooth = TRUE)

# 5. Disable JavaScript (for static HTML export)
make_fig(spec, "column", use_js = FALSE)

# 6. Save
hd_save(make_fig(spec, "column"), "chart.html")
hd_save(make_fig(spec, "column", backend = "ggplot2"), "chart.png")
```

------------------------------------------------------------------------

## Theming

``` r
# Set package-wide defaults for the session
hd_set_theme(
  hc_theme = "economist",
  colors   = c("#025169", "#7C145C", "#C68803"),
  font     = "Source Sans Pro"
)

# All subsequent make_fig() calls use these settings automatically
make_fig(spec, "column")
```

------------------------------------------------------------------------

## JavaScript injection

``` r
fig <- make_fig(spec, "column")

# Inline JS
fig <- hd_add_js(fig, code = "console.log('chart loaded');")

# From a .js file
fig <- hd_add_js(fig, file = "path/to/my-plugin.js")

# From a bundled plugin (inst/js/<name>.js)
fig <- hd_add_js(fig, plugin = "my-plugin")
```

------------------------------------------------------------------------

## Shiny GUI

``` r
run_app()
```

------------------------------------------------------------------------

## Supported geometries

| Name | highcharter type | ggplot2 equivalent | Extra args |
|:---|:---|:---|:---|
| `column` | column | `geom_col()` | — |
| `line` | line / spline | `geom_line()` | `smooth`, `dot_size`, `line_symbols` |
| `scatter` | scatter | `geom_point()` | — |
| `arearange` | arearange | `geom_ribbon()` | `ymin`, `ymax` |

------------------------------------------------------------------------

## License

MIT © Kamaleri
