# Set Package-Wide Style Defaults

Configures default theme, colour palette, font, and JavaScript plugins
for all figures produced with
[`make_fig()`](https://github.com/folkehelsestats/highdir/reference/make_fig.md)
in the current R session. Call once at the top of a script or in
`.Rprofile` for consistent styling.

## Usage

``` r
hd_set_theme(hc_theme = NULL, colors = NULL, font = NULL, js_plugins = NULL)
```

## Arguments

- hc_theme:

  Character or `NULL`. Name of a built-in highcharter theme. One of
  `"default"`, `"smpl"`, `"economist"`, `"darkunica"`, `"gridlight"`,
  `"bloom"`, `"flat"`, `"flatdark"`, `"ggplot2"`.

- colors:

  Character vector or `NULL`. Hex colour codes applied to every figure
  (both backends). When `NULL` the hdir default palette or the theme
  colours are used.

- font:

  Character or `NULL`. Font family string, e.g. `"Source Sans Pro"`.
  `NULL` uses the theme/system font.

- js_plugins:

  Character vector or `NULL`. Names of bundled JS plugins (files in
  `inst/js/`) to inject into every highcharter figure. Supply
  `character(0)` to clear.

## Value

The previous option values, invisibly, so you can restore them with
`options(hd_set_theme(...))` if needed.

## Examples

``` r
# Use the economist theme with custom colours
hd_set_theme(hc_theme = "economist",
             colors   = c("#025169", "#7C145C", "#C68803"))
#> Error in hd_set_theme(hc_theme = "economist", colors = c("#025169", "#7C145C",     "#C68803")): could not find function "hd_set_theme"

# Reset to defaults
hd_set_theme(hc_theme = "default", colors = NULL)
#> Error in hd_set_theme(hc_theme = "default", colors = NULL): could not find function "hd_set_theme"
```
