# highdir

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

The simplest way to get started with *highdir* is by using the built‑in
Shiny app. Its source code also demonstrates how to use the package
programmatically in R. Start the app with:

``` r
hd_app()
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
