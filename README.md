
<!-- README.md is generated from README.Rmd. Please edit that file -->

# highdir <a href="https://github.com/folkehelsestats/highdir"><img src="man/figures/logo.png" align="right" height="120" alt="highdir website" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/folkehelsestats/highdir/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/folkehelsestats/highdir/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/folkehelsestats/highdir/graph/badge.svg)](https://app.codecov.io/gh/folkehelsestats/highdir)

<!-- badges: end -->

**highdir** is an R package that provides a unified, backend-agnostic
API for building figures with either
[**highcharter**](https://jkunst.com/highcharter/) (interactive) or
[**ggplot2**](https://ggplot2.tidyverse.org/) (static).

A figure is described once as a `hd_spec` object and rendered to any
supported backend without changing the calling code. Additional
presentation settings can be defined through `hc_opts` prior to
rendering. The package ships with the default to use [The Norwegian
Directorate of Health](https://www.helsedirektoratet.no)
(*Helsedirektoratet*) colour palette, styling and theme. To enhance
usability, a Shiny graphical user interface is also included.

------------------------------------------------------------------------

## Installation

``` r
# Install from GitHub
remotes::install_github("folkehelsestats/highdir")
# Install from development version (dev branch)
remotes::install_github("folkehelsestats/highdir@dev")
```

------------------------------------------------------------------------

## Get started

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
