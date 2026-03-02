# Resolve colour vector for n groups

Returns a character vector of `n` colours using the hdir palette for 1–7
groups, a two-colour teal/purple pair for exactly 2 groups, and viridis
for 8+ groups.

## Usage

``` r
resolve_colors(n, colors = NULL)
```

## Arguments

- n:

  Integer. Number of groups / series.

- colors:

  Optional override vector supplied by the user or from
  `getOption("highdir.colors")`. If non-NULL and long enough, it is used
  directly.

## Value

Character vector of length `n`.
