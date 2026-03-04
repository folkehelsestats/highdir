# Register a Geometry

Adds a named geometry to the geom registry. A geometry pairs a ggplot2
layer function with a highcharter series function.

## Usage

``` r
register_geom(
  name,
  ggplot_fun = NULL,
  highcharter_fun = NULL,
  required_args = character(),
  is_map_geom = FALSE
)
```

## Arguments

- name:

  Character. Unique geometry identifier.

- ggplot_fun:

  Function or `NULL`. ggplot2 layer builder.

- highcharter_fun:

  Function or `NULL`. highcharter series builder.

- required_args:

  Character vector. Names of required `geom_params` entries beyond x/y
  (e.g. `c("ymin", "ymax")` for `"arearange"`).

## Value

`name`, invisibly.

## Details

The geom functions receive `(spec, opts, geom_params, ...)` for ggplot2
and `(chart, spec, opts, geom_params, use_js, ...)` for highcharter.
`geom_params` is a named list containing all geom-specific arguments
(e.g. `smooth`, `dot_size`, `ymin`, `ymax`).

## Examples

``` r
if (FALSE) { # \dontrun{
register_geom(
  "violin",
  ggplot_fun      = function(spec, opts, geom_params, ...) ggplot2::geom_violin(),
  highcharter_fun = NULL,   # highcharter has no violin
  required_args   = character()
)
} # }
```
