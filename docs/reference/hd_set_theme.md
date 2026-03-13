# Set Package-Wide Style Defaults

Configures the default theme, colour palette, font, and optional
JavaScript plugins for all figures produced with
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)
in the current R session. Call once at the top of a script or in
`.Rprofile`.

## Usage

``` r
hd_set_theme(
  hc_theme = NULL,
  gg_theme = NULL,
  colors = NULL,
  font = NULL,
  js_plugins = NULL
)
```

## Arguments

- hc_theme:

  Character or `NULL`. Built-in highcharter theme name: one of
  `"default"`, `"smpl"`, `"economist"`, `"darkunica"`, `"gridlight"`,
  `"bloom"`, `"flat"`, `"flatdark"`, `"ggplot2"`.

- gg_theme:

  Character, ggplot2 theme object, or `NULL`. Controls the ggplot2
  backend appearance. Built-in name strings: `"minimal"` (default),
  `"classic"`, `"bw"`, `"light"`, `"dark"`, `"void"`, `"grey"`.
  Alternatively pass any `ggplot2::theme_*()` object directly for full
  control, e.g. `ggplot2::theme_bw(base_size = 14)`.

- colors:

  Character vector, palette name, or `NULL`. Applied to all figures in
  the session. See
  [`register_palette()`](https://github.com/folkehelsestats/highdir/reference/register_palette.md).

- font:

  Character or `NULL`. Font family name, e.g. `"Source Sans Pro"`.

- js_plugins:

  Character vector or `NULL`. Names of bundled JS plugins (files in
  `inst/js/`) injected into every highcharter figure. Use `character(0)`
  to clear all plugins.

## Value

The previous option values invisibly; pass to
[`options()`](https://rdrr.io/r/base/options.html) to restore.

## Details

Per-figure overrides are provided via
[`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md),
which always take precedence over these session defaults.

## See also

[`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md)
for per-figure overrides

## Examples

``` r
hd_set_theme(hc_theme = "economist", gg_theme = "classic",
             colors   = c("#025169", "#7C145C", "#C68803"))
#> Error in hd_set_theme(hc_theme = "economist", gg_theme = "classic", colors = c("#025169",     "#7C145C", "#C68803")): unused argument (gg_theme = "classic")
# Reset
hd_set_theme(hc_theme = "default", gg_theme = "minimal", colors = NULL)
#> Error in hd_set_theme(hc_theme = "default", gg_theme = "minimal", colors = NULL): unused argument (gg_theme = "minimal")
```
