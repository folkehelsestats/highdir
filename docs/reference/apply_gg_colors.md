# Apply brand colours to a ggplot object

Uses the same
[`resolve_colors()`](https://github.com/folkehelsestats/highdir/reference/resolve_colors.md)
priority chain as the highcharter engine so both backends always produce
identical colour assignments:

## Usage

``` r
apply_gg_colors(p, colors = NULL, n_groups = NULL, group_levels = NULL)
```

## Arguments

- p:

  A ggplot object.

- colors:

  Character vector, palette name string, or NULL.

- n_groups:

  Integer. Number of groups in the data. Drives which palette rule
  fires. Passed from `ggplot_engine()`.

- group_levels:

  Character vector or NULL. Group level names in data order. Used to
  name the palette so ggplot2 matches colours to groups by name rather
  than alphabetical sort.

## Value

The modified ggplot object.

## Details

1.  Explicit `colors` argument

2.  `getOption("highdir.colors")` session default

3.  Built-in rules: n==2 → hdir2, n\<=10 → hdir\[1:n\], n\>10 → viridis
