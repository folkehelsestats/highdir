# Build a Highcharts Theme Object

Constructs a highcharter theme by merging a named base theme with colour
and font overrides from the current
[`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md)
session defaults and any per-figure `opts`.

## Usage

``` r
hd_theme(name = NULL, colors = NULL, ...)
```

## Arguments

- name:

  Character or `NULL`. Theme name; `NULL` reads from
  `getOption("highdir.hc_theme")`.

- colors:

  Character vector or `NULL`. Colour override for this call.

- ...:

  Named arguments forwarded to
  [`highcharter::hc_theme()`](https://jkunst.com/highcharter/reference/hc_theme.html)
  as extra overrides on top of the base theme.

## Value

A highcharter theme object (`hc_theme`).

## Details

Called automatically inside the highcharter engine; useful when you want
to apply a theme to a highchart built outside highdir.

## Examples

``` r
if (FALSE) { # \dontrun{
t <- hd_theme("darkunica")
highcharter::highchart() |> highcharter::hc_add_theme(t)
} # }
```
