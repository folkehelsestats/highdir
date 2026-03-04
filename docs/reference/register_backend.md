# Register a Rendering Backend

Adds a named engine function to the backend registry. The engine
receives `(spec, geom, opts, geom_params, use_js, filename)` and must
return a rendered figure object (`ggplot` or `highchart`).

## Usage

``` r
register_backend(name, engine)
```

## Arguments

- name:

  Character. Unique backend identifier (e.g. `"ggplot2"`).

- engine:

  Function with signature
  `function(spec, geom, opts, geom_params, use_js, filename, ...)`.

## Value

`name`, invisibly.

## Details

Third-party packages call this in their own `.onLoad()` to add backends
such as `"plotly"` or `"echarts4r"`.

## Examples

``` r
if (FALSE) { # \dontrun{
my_engine <- function(spec, geom, opts, geom_params, use_js, filename, ...) {
  # return a rendered figure
}
register_backend("my_backend", my_engine)
list_backends()
} # }
```
