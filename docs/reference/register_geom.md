# Register a Geometry

Adds a geometry to the registry. The `optional_args` field is the key
mechanism for user discoverability: it is what
[`geom_args()`](https://github.com/folkehelsestats/highdir/reference/geom_args.md)
prints, what the Shiny app reads to build dynamic UI, and what automated
documentation can harvest without parsing source code.

## Usage

``` r
register_geom(
  name,
  ggplot_fun = NULL,
  highcharter_fun = NULL,
  required_args = list(),
  optional_args = list(),
  is_map_geom = FALSE
)
```

## Arguments

- name:

  Character. Unique geometry identifier.

- ggplot_fun:

  Function or `NULL`.

- highcharter_fun:

  Function or `NULL`.

- required_args:

  Named list of `list(default, desc)`. Args that MUST be supplied via
  `...` in
  [`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md).
  Validation fails if any are missing.

- optional_args:

  Named list of `list(default, desc)`. Args that MAY be supplied and
  have a sensible default when omitted. These are purely informational
  from the registry's perspective - the geom function applies the
  defaults itself via `geom_params$key %||% default`.

- is_map_geom:

  Logical. Bypasses
  [`base_fig()`](https://github.com/folkehelsestats/highdir/reference/base_fig.md)
  in both engines.

## Value

`name`, invisibly.

## Details

Structure of `optional_args`: A named list where each element is itself
a list with two fields: `default` - the value used when the arg is not
supplied (may be `NULL`) `desc` - a short human-readable description
(shown by
[`geom_args()`](https://github.com/folkehelsestats/highdir/reference/geom_args.md))

Example:

    optional_args = list(
      smooth   = list(default = TRUE,  desc = "Spline smoothing (logical)"),
      dot_size = list(default = 4,     desc = "Marker radius in px (numeric)")
    )
