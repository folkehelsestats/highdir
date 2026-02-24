
<!-- README.md is generated from README.Rmd. Please edit that file -->

# highdir <img src='man/figures/logo.png' align="right" width="120" height="138" />

## Overview

**highdir** provides pre‑configured Highcharts figure templates tailored
for the Norwegian Directorate of Health (Helsedirektoratet). The package
is based on [highcharter](https://jkunst.com/highcharter/ "highcharter")
package and [ggplot2](https://ggplot2.tidyverse.org/ "ggplot2") package.

The package is still in **experimental version**, and both the API and
visual design may change in future releases.

Documentation can be found here
<https://folkehelsestats.github.io/highdir/>

## Installation

You can install *highdir* package directly from Github:

``` r
if(!require(remotes)) install.packages("remotes")
remotes::install_github("folkehelsestats/highdir")
```

or installing the development version.

``` r
if(!require(remotes)) install.packages("remotes")
remotes::install_github("folkehelsestats/highdir", ref = "dev")
```

## Usage

The easiest way to get started is by launching the built‑in graphical
interface (GUI):

<img src="man/img/README-unnamed-chunk-4-1.png" alt="" width="70%" />

This opens an interactive tool for generating and exporting figures
using prefered templates.

## Feedback & Contributions

Because highdir is experimental, feedback, issue reports, and
suggestions are very welcome.

Please open an issue or pull request on GitHub if you would like to
contribute.
