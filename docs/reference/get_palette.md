# Retrieve a Named Palette

Retrieve a Named Palette

## Usage

``` r
get_palette(name)
```

## Arguments

- name:

  Character. Palette name (see
  [`list_palettes()`](https://github.com/folkehelsestats/highdir/reference/list_palettes.md)).

## Value

Character vector of colours, or `NULL` if not found.

## Examples

``` r
get_palette("hdir")
#>  [1] "#025169" "#0069E8" "#7C145C" "#C68803" "#047FA4" "#38A389" "#6996CE"
#>  [8] "#366558" "#BF78DE" "#767676"
```
