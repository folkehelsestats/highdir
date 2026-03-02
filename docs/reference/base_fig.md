# Base Figure Canvas

Constructs the blank backend-specific canvas (a bare `ggplot` or
`highchart`) with axes, labels, and chart-level options applied from
`spec`. Called internally by the backend engines; you rarely need this
directly.

## Usage

``` r
base_fig(spec, backend)
```

## Arguments

- spec:

  A
  [fig_spec](https://github.com/folkehelsestats/highdir/reference/fig_spec.md)
  object.

- backend:

  Character. Backend name, e.g. `"ggplot2"` or `"highcharter"`.

## Value

A `ggplot` or `highchart` object.
