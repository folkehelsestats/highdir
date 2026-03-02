# Inject JavaScript into a Highcharts Widget

Appends custom JavaScript to a `highchart` object. Useful for Highcharts
plugins, custom `load` / `render` callbacks, or any other JS that must
run in the chart's context.

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

  A `highchart` object (output of
  [`make_fig()`](https://github.com/folkehelsestats/highdir/reference/make_fig.md)
  with `backend = "highcharter"`, or any object returned by
  [`highcharter::highchart()`](https://jkunst.com/highcharter/reference/highchart.html)).

- code:

  Character or `NULL`. Raw JavaScript string.

- file:

  Character or `NULL`. Path to a `.js` file whose contents are read and
  injected.

- plugin:

  Character or `NULL`. Name of a JS plugin bundled with highdir (a file
  at `inst/js/<plugin>.js`). Convenient shorthand for
  `file = system.file(...)`.

- where:

  Character. One of `"load"` (default) — runs when the chart finishes
  loading — or `"render"` — runs after every render cycle.

## Value

The `highchart` object with the JS injected via `chart.events.<where>`.

## Details

Exactly one of `code`, `file`, or `plugin` must be supplied.

## Examples

``` r
if (FALSE) { # \dontrun{
spec <- fig_spec(mtcars, "wt", "mpg")
fig  <- make_fig(spec, "scatter", backend = "highcharter")
fig  <- hd_add_js(fig, code = "console.log('chart loaded');")
} # }
```
