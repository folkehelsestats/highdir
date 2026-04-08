# ggplot2 Arearange Geom Function

Returns a list of ggplot2 layers (ribbon + optional centre line +
points) that the ggplot2 engine adds to the base figure. Not intended to
be called directly; use
[`hd_geom_arearange()`](https://github.com/folkehelsestats/highdir/reference/hd_geom_arearange.md)
or `hd_make(..., type = "arearange")`.

## Usage

``` r
gg_arearange(spec, opts, geom_params)
```

## Arguments

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

## Value

A list of `ggplot2` layer objects.

## geom_params recognised

- `ymin`:

  Character. **Required.** Column name for the lower bound.

- `ymax`:

  Character. **Required.** Column name for the upper bound.

- `show_line`:

  Logical. Draw a centre line + open-circle points on top of the ribbon.
  Default `TRUE`.

- `single_colour`:

  Character or `NULL`. Fixed hex colour injected by the ggplot2 engine
  for single-series figures. `NULL` for multi-series figures (colour is
  handled by
  [`apply_gg_colors()`](https://github.com/folkehelsestats/highdir/reference/apply_gg_colors.md)).
