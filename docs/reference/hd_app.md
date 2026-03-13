# Launch the highdir Shiny GUI

Opens an interactive browser-based application for building figures with
`highcharter` or `ggplot2` without writing R code.

## Usage

``` r
hd_app(return.app = FALSE)
```

## Arguments

- return.app:

  Logical. When deploying to server like Shiny.io to return the app
  object instead of launching it.

## Value

Launches a Shiny app; does not return a value.

## Details

The UI (`inst/app/ui.R`), server (`inst/app/server.R`) and shared setup
(`inst/app/global.R`) live in `inst/app/` so the folder can be deployed
independently to Shiny Server or shinyapps.io.

## Features

- Upload datasets in any format supported by **rio** (CSV, XLSX, SPSS,
  Stata, RDS, …).

- Choose geometry (`column`, `line`, `scatter`, `arearange`, `pie`),
  backend, axis variables, and group column.

- Set title, subtitle, caption, colour palette, and HC theme.

- Toggle JS hover band per figure.

- Render on demand with the **Draw** button.

- Download as HTML / JSON / PNG (highcharter) or PNG / SVG (ggplot2).

- Copy the equivalent
  [`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)
  call from the **R code** tab.

## See also

[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md),
[`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md),
[`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md),
[`hd_save()`](https://github.com/folkehelsestats/highdir/reference/hd_save.md)
