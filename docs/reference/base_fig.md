# Build a Blank Backend Canvas

Constructs the empty backend object (ggplot or highchart) with all
chart-level options applied from `spec` and `opts`. Called by the
backend engines; you rarely need this directly.

## Usage

``` r
base_fig(spec, opts, backend)
```

## Arguments

- spec:

  A
  [hd_spec](https://github.com/folkehelsestats/highdir/reference/hd_spec.md)
  object.

- opts:

  A
  [hd_opts](https://github.com/folkehelsestats/highdir/reference/hd_opts.md)
  object.

- backend:

  Character. Backend name.

## Value

A `ggplot` or `highchart` object.
