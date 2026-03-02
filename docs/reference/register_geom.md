# Register a Geometry

Adds a named geometry to the registry. A geometry pairs a ggplot2 layer
function with a highcharter series function, along with any required
arguments beyond x/y.

## Usage

``` r
register_geom(
  name,
  ggplot_fun = NULL,
  highcharter_fun = NULL,
  required_args = character()
)
```

## Arguments

- name:

  Character. Unique geometry identifier (e.g. `"line"`).

- ggplot_fun:

  Function. Called as `ggplot_fun(spec, ...)` inside the ggplot2 engine;
  must return a ggplot2 layer.

- highcharter_fun:

  Function. Called as `highcharter_fun(chart, spec, ...)` inside the
  highcharter engine; must return a `highchart` object.

- required_args:

  Character vector. Names of arguments (beyond x/y) that the geometry
  requires (e.g. `c("ymin", "ymax")` for `arearange`).

## Value

`name`, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
register_geom("violin",
  ggplot_fun      = function(spec, ...) ggplot2::geom_violin(...),
  highcharter_fun = function(chart, spec, ...) { ... }
)
} # }
```
