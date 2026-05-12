# Register a Named Colour Palette

Adds a named palette to the highdir palette registry so it can be
referenced by name wherever colours are accepted (e.g.
`hd_opts(colors = "my_palette")`). This function is evaluated when
loading a file in zzz.R file.

## Usage

``` r
register_palette(name, colors)
```

## Arguments

- name:

  Character. Unique palette identifier.

- colors:

  Non-empty character vector of CSS/hex colour strings.

## Value

`name`, invisibly.

## Details

Built-in palettes registered at package load time:

|           |                                           |
|-----------|-------------------------------------------|
| Name      | Description                               |
| `"hdir"`  | Helsedirektoratet 10-colour brand palette |
| `"hdir2"` | 2-colour teal / purple pair               |

## Examples

``` r
register_palette("blues", c("#084594", "#2171b5", "#4292c6", "#6baed6"))
get_palette("blues")
#> [1] "#084594" "#2171b5" "#4292c6" "#6baed6"
```
