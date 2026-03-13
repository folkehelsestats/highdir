# Resolve a ggplot2 Theme Object

Returns a ggplot2 theme object from either a name string or a theme
object passed directly. Priority: explicit argument \> session option
(`highdir.gg_theme`) \> `"minimal"` fallback.

## Usage

``` r
gg_theme(theme = NULL)
```

## Arguments

- theme:

  Character name string, ggplot2 theme object, or `NULL`. `NULL` reads
  from `getOption("highdir.gg_theme")`.

## Value

A ggplot2 `theme` object.

## Details

Called automatically inside `ggplot_engine()`; useful when you want to
apply the package theme to a ggplot built outside highdir.

Built-in name strings and their ggplot2 equivalents:

|                       |                   |
|-----------------------|-------------------|
| Name                  | ggplot2 function  |
| `"minimal"` (default) | `theme_minimal()` |
| `"classic"`           | `theme_classic()` |
| `"bw"`                | `theme_bw()`      |
| `"light"`             | `theme_light()`   |
| `"dark"`              | `theme_dark()`    |
| `"void"`              | `theme_void()`    |
| `"grey"` / `"gray"`   | `theme_grey()`    |

## Examples

``` r
gg_theme()                          # reads session default
#> Error in gg_theme(): could not find function "gg_theme"
gg_theme("classic")                 # theme_classic()
#> Error in gg_theme("classic"): could not find function "gg_theme"
gg_theme(ggplot2::theme_bw(base_size = 14))  # object passed directly
#> Error in gg_theme(ggplot2::theme_bw(base_size = 14)): could not find function "gg_theme"
```
