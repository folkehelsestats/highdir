# Inject JavaScript into a Highcharts Widget

Appends custom JavaScript to a `highchart` object via
`chart.events.<where>`. Use this for hand-written callbacks and plugins.
For Highcharts built-in modules (accessibility, exporting, etc.) use
[`highcharter::hc_add_dependency()`](https://jkunst.com/highcharter/reference/hc_add_dependency.html)
instead.

## Usage

``` r
hd_add_js(
  hc,
  code = NULL,
  file = NULL,
  plugin = NULL,
  where = c("load", "render")
)
```

## Arguments

- hc:

  A `highchart` object.

- code:

  Character or `NULL`. Raw JavaScript string.

- file:

  Character or `NULL`. Path to a `.js` file to read and inject.

- plugin:

  Character or `NULL`. Name of a plugin bundled in `inst/js/`.

- where:

  `"load"` (default) or `"render"`.

## Value

The `highchart` object with JS injected.

## Details

Exactly one of `code`, `file`, or `plugin` must be supplied.

## Examples

``` r
if (FALSE) { # \dontrun{
spec <- hd_spec(mtcars, "wt", "mpg")
fig  <- hd_make(spec, "scatter")
fig  <- hd_add_js(fig, code = "console.log('chart loaded');")
} # }
```
