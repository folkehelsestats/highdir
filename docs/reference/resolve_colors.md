# Resolve a Colour Vector for n Groups

Returns exactly `n` colours. Priority order:

## Usage

``` r
resolve_colors(n, colors = NULL)
```

## Arguments

- n:

  Integer. Number of colours required.

- colors:

  Character vector, palette name, or `NULL`.

## Value

Character vector of exactly length `n`.

## Details

1.  Explicit `colors` argument — vector or palette name string.

2.  `getOption("highdir.colors")` — set via
    [`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md).

3.  Built-in hdir rules:

    - n == 2 → `"hdir2"` two-colour teal/purple pair

    - n \<= 10 → `"hdir"` 10-colour brand palette

    - n \> 10 → viridis continuous scale
