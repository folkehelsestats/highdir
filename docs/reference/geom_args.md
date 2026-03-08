# Show Arguments for a Geometry

Prints the required and optional `...` arguments accepted by a geometry
when used with
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md).
This is the primary discoverability tool for geometry-specific arguments
that do not appear in
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)'s
signature.

## Usage

``` r
geom_args(type = NULL)
```

## Arguments

- type:

  Character. Geometry name, e.g. `"line"`, `"ranked_bar"`. If `NULL`
  (default), prints a summary for every registered geometry.

## Value

A data frame of argument metadata, invisibly. The primary purpose is the
side-effect of printing.

## Why this exists

[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)
uses `...` for all geometry-specific arguments so its own signature
stays clean regardless of how many geometries are registered. The
trade-off is that users cannot see available args from
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)
alone. `geom_args()` solves that: it reads the `required_args` and
`optional_args` fields registered for each geometry and presents them in
a readable table.

## Examples

``` r
geom_args("line")
#> Error in geom_args("line"): could not find function "geom_args"
geom_args("ranked_bar")
#> Error in geom_args("ranked_bar"): could not find function "geom_args"
geom_args("arearange")
#> Error in geom_args("arearange"): could not find function "geom_args"
geom_args()           # all registered geometries
#> Error in geom_args(): could not find function "geom_args"
```
