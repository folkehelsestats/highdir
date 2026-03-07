
<!-- README.md is generated from README.Rmd. Please edit that file -->

# highdir <img src='man/figures/logo.png' alt="Package logo" align="right" width="120" height="138" />

**highdir** is an R package that provides a unified, backend-agnostic
API for building figures with either
[**highcharter**](https://jkunst.com/highcharter/) (interactive) or
[**ggplot2**](https://ggplot2.tidyverse.org/) (static).

A figure is described once as a `hd_spec` and `hd_opts` object and
rendered to either backend without changing the calling code. The
package ships with the default to use Helsedirektoratet colour palette,
styling and theme. A Shiny GUI is introduced to make it user friendly.

------------------------------------------------------------------------

## Installation

``` r
# Install from GitHub
remotes::install_github("folkehelsestats/highdir")
# Install from development version (dev branch)
remotes::install_github("folkehelsestats/highdir@dev")
```

------------------------------------------------------------------------

## Shiny GUI

This is the fastest way to start using **highdir** package.

``` r
hd_app()
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

# Figure data specification 
spec <- hd_spec(df, x = "age", y = "pct", group = "sex", n = "n")

# Specify figure presentation
opts <- hd_opts(title = "Health survey",
                subtitle = "Source: Example data",
                caption  = "Tall om helse"
                ylim = c(0, 80))

hd_make(spec, "column", opts)                       # highcharter (default)
hd_make(spec, "column", opts, backend = "ggplot2")  # static ggplot2
hd_make(spec, "line",   opts, smooth = TRUE)        # smooth spline
hd_make(spec, "pie",    opts)                       # pie / donut

# Disable JavaScript (for static HTML export)
hd_make(spec, "column", opts, use_js = FALSE)

# Save
hd_save(hd_make(spec, "column"), "chart.html")
hd_save(hd_make(spec, "column", backend = "ggplot2"), "chart.png")
```

------------------------------------------------------------------------

## Theming

``` r
# Set package-wide defaults for the session
hd_set_theme(
  hc_theme = "helsedirektoratet",
  colors   = c("#025169", "#7C145C", "#C68803"),
  font     = "Source Sans Pro"
)

# All subsequent hd_make() calls use these settings automatically
hd_make(spec, "column")
```

------------------------------------------------------------------------

## JavaScript injection

``` r
fig <- hd_make(spec, "column")

# Inline JS
fig <- hd_add_js(fig, code = "console.log('chart loaded');")

# From a .js file
fig <- hd_add_js(fig, file = "path/to/my-plugin.js")

# From a bundled plugin (inst/js/<name>.js)
fig <- hd_add_js(fig, plugin = "my-plugin")
```

------------------------------------------------------------------------

## Supported geometries

| Name | highcharter type | ggplot2 equivalent | Extra args |
|:---|:---|:---|:---|
| `column` | column | `geom_col()` | — |
| `line` | line / spline | `geom_line()` | `smooth`, `dot_size`, `line_symbols` |
| `scatter` | scatter | `geom_point()` | — |
| `arearange` | arearange | `geom_ribbon()` | `ymin`, `ymax` |
| `pie` | pie | `geom_bar()`, `coord_polar()` | — |

------------------------------------------------------------------------

## License

MIT © Kamaleri
