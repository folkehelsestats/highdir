# Render an hd Object

Printing an
[`hd()`](https://github.com/folkehelsestats/highdir/reference/hd.md)
object triggers rendering. The geometry type and any geometry-specific
parameters are extracted from the stored `hd_geom` layer; presentation
options from the `hd_opts` layer; the backend from the `$backend` slot.
All of these are forwarded to
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md),
which performs the actual rendering via the registered engine.

## Usage

``` r
# S3 method for class 'hd'
print(x, ...)
```

## Arguments

- x:

  An `hd` object.

- ...:

  Ignored; present for S3 consistency.

## Value

The rendered output (a `highchart` widget or a `ggplot` object),
invisibly.

## Details

You rarely need to call `print.hd()` directly since R calls it
automatically when the object appears at the top level, in knitr/Quarto
chunks, or in Shiny `renderHighchart()` / `renderPlot()` blocks.
