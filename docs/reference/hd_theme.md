# Build a Highcharts Theme Object

Constructs a highcharter theme by merging a named base theme with colour
and font overrides from the current
[`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md)
settings and any extra named arguments passed via `...`.

## Usage

``` r
hd_theme(name = NULL, ...)
```

## Arguments

- name:

  Character or `NULL`. Theme name. `NULL` reads from
  `getOption("highdir.hc_theme")`.

- ...:

  Named arguments forwarded to
  [`highcharter::hc_theme()`](https://jkunst.com/highcharter/reference/hc_theme.html)
  as overrides on top of the base theme. See the Highcharts API for the
  expected structure.

## Value

A highcharter theme object (a named list of class `"hc_theme"`).

## Details

You normally do not need to call this directly —
[`make_fig()`](https://github.com/folkehelsestats/highdir/reference/make_fig.md)
applies it automatically for `backend = "highcharter"`. Use it when you
want to preview or apply a theme to a highchart object built outside
highdir.

## Examples

``` r
if (FALSE) { # \dontrun{
t <- hd_theme("darkunica")
highcharter::highchart() |> highcharter::hc_add_theme(t)
} # }
```
