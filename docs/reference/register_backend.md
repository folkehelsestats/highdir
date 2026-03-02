# Register a Rendering Backend

Adds a named backend engine to the registry. An engine is a function
with the signature `function(spec, geom, ...)` that returns a rendered
figure object (a `ggplot` or `highchart`).

## Usage

``` r
register_backend(name, engine)
```

## Arguments

- name:

  Character. Unique backend identifier (e.g. `"ggplot2"`).

- engine:

  A function with signature `function(spec, geom, ...)`.

## Value

`name`, invisibly.

## Details

Third-party packages can call `register_backend()` to add their own
backends (e.g. `"plotly"`).

## Examples

``` r
if (FALSE) { # \dontrun{
my_engine <- function(spec, geom, ...) { ... }
register_backend("my_backend", my_engine)
} # }
```
