# highdir

**highdir** is an R package that provides a unified, backend-agnostic
API for building figures with either
[**highcharter**](https://jkunst.com/highcharter/) (interactive) or
[**ggplot2**](https://ggplot2.tidyverse.org/) (static).

A figure is described once as a `hd_spec` and `hd_opts` object and
rendered to either backend without changing the calling code. The
package ships with the default to use [The Norwegian Directorate of
Health](https://www.helsedirektoratet.no) (*Helsedirektoratet*) colour
palette, styling and theme. A Shiny GUI is introduced to make it user
friendly.

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
Shiny app. It shows also codes to demonstrate how to use the package
programmatically in R. Start the app with:

``` r
hd_app()
```

The app is also available directly through ShinyApps.io at:
<https://bit.ly/highdir>

------------------------------------------------------------------------

## Supported geometries

| Name | highcharter type | ggplot2 equivalent | Extra args |
|:---|:---|:---|:---|
| `column` | column | `geom_col()` | — |
| `ranked_bar` | column | `geom_col()` | `comp`, `aim` |
| `line` | line / spline | `geom_line()` | `smooth`, `dot_size`, `line_symbols` |
| `scatter` | scatter | `geom_point()` | — |
| `arearange` | arearange | `geom_ribbon()` | `ymin`, `ymax` |
| `pie` | pie | `geom_bar()`, `coord_polar()` | — |

------------------------------------------------------------------------

To see complete list of extra arguments for specify geoms use:

``` r
geom_args("ranked_bar")
geom_args("arearange")
```

## License

MIT © Kamaleri
