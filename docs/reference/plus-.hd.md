# Add Layers to an hd Object

Implements the `+` operator for
[`hd()`](https://github.com/folkehelsestats/highdir/reference/hd.md)
objects, mirroring how `ggplot2` builds plots incrementally. Recognised
right-hand sides:

## Usage

``` r
# S3 method for class 'hd'
e1 + e2
```

## Arguments

- e1:

  An `hd` object (left-hand side).

- e2:

  An `hd_geom` or `hd_opts` object (right-hand side).

## Value

The updated `hd` object (invisibly, so the chain prints once).

## Details

- `hd_geom` object:

  Sets the geometry (from any `hd_geom_*()` call). Adding a second geom
  replaces the first where highdir renders one geometry per figure.

- `hd_opts` object:

  Sets presentation options. Adding a second `hd_opts` replaces the
  first.

Unknown right-hand sides produce an informative error rather than
silently being ignored.

## Examples

``` r
df <- data.frame(age = c("18-24", "25-34"), pct = c(42, 55))

# Chain layers
p <- hd(df, x = "age", y = "pct") +
  hd_geom_column() +
  hd_opts(title = "Demo")

# Reuse a partial object with different opts
base <- hd(df, x = "age", y = "pct") + hd_geom_column()
base + hd_opts(title = "English title")
base + hd_opts(title = "Norsk tittel")
```
