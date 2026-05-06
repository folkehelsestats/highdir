# Geometry Layers for hd Objects

Each `hd_geom_*()` function creates a geometry layer that is added to an
[`hd()`](https://github.com/folkehelsestats/highdir/reference/hd.md)
object via `+`. The layer records the geometry type and any
geometry-specific arguments; rendering only happens when the `hd` object
is printed.

## Arguments

- ...:

  Geometry-specific arguments forwarded to
  [`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md).
  Use
  [`geom_args()`](https://github.com/folkehelsestats/highdir/reference/geom_args.md)
  to discover available arguments per geometry, e.g. `geom_args("line")`
  lists `smooth`, `dot_size`, `line_symbols`.

## Value

An S3 object of class `"hd_geom"` for use with `+.hd`.

## Details

Geometry-specific arguments (`...`) are forwarded to
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)
as the `...` pass-through which they are the same arguments documented
by
[`geom_args()`](https://github.com/folkehelsestats/highdir/reference/geom_args.md).

## See also

[`hd()`](https://github.com/folkehelsestats/highdir/reference/hd.md),
[`list_geoms()`](https://github.com/folkehelsestats/highdir/reference/list_geoms.md),
[`geom_args()`](https://github.com/folkehelsestats/highdir/reference/geom_args.md),
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)
