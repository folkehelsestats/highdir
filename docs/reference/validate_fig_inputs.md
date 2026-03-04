# Validate inputs before rendering a figure

Called by
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md)
immediately before dispatching to a backend engine. Stops with an
informative message if anything is wrong.

## Usage

``` r
validate_fig_inputs(spec, opts, type, backend, extra_args)
```

## Arguments

- spec:

  A `hd_spec` object.

- opts:

  A `hd_opts` object.

- type:

  Character. Geometry name.

- backend:

  Character. Backend name.

- extra_args:

  Named list of additional arguments (for required-arg check).

## Value

`invisible(NULL)` on success.
