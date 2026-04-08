# Highcharter Arearange Geom Function

Adds an arearange series (and optionally a linked centre-line series) to
a partially-built `highchart` object. Not intended to be called
directly; use
[`hd_geom_arearange()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_arearange.md)
or `hd_make(..., type = "arearange")`.

## Usage

``` r
hc_arearange(chart, spec, opts, geom_params, use_js = TRUE, ...)
```

## Arguments

- chart:

  A `highchart` object (from
  [`base_fig()`](https://github.com/folkehelsestats/highdir/reference/base_fig.md)).

- spec:

  An
  [`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md)
  object.

- opts:

  An
  [`hd_opts()`](https://github.com/folkehelsestats/highdir/reference/hd_opts.md)
  object.

- geom_params:

  Named list of geom-specific arguments (see above).

- use_js:

  Logical. Inject the hover-band JS callback. Default `TRUE`.

- ...:

  Unused; present for engine-contract consistency.

## Value

The updated `highchart` object.

## Series strategy

For each group in `spec$data` two Highcharts series are added:

1.  A `"line"` series for the centre values (`spec$y`), rendered first
    so it appears on top (higher z-index). This series owns the legend
    entry (`showInLegend = TRUE`).

2.  An `"arearange"` series for the confidence band, linked back to the
    line series via `linkedTo = line_id`. This means clicking the legend
    hides *both* line and band together. `showInLegend = FALSE` avoids a
    duplicate legend entry.

When `show_line = FALSE` only the arearange series is added, and it owns
the legend entry itself.

## geom_params recognised

- `ymin`:

  Character. **Required.** Column name for the lower bound.

- `ymax`:

  Character. **Required.** Column name for the upper bound.

- `show_line`:

  Logical. Overlay the centre line. Default `TRUE`.
