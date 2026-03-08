# Create Figure Presentation Options

Defines the **visual presentation** of a figure independently from the
data mapping. Pass the result as the `opts` argument of
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md),
or omit it to accept all defaults.

## Usage

``` r
hd_opts(
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  xlab = " ",
  ylab = " ",
  ylim = NULL,
  yint = 10,
  flip = FALSE,
  colors = NULL,
  hc_theme = NULL
)
```

## Arguments

- title:

  Character or `NULL`. Chart title.

- subtitle:

  Character or `NULL`. Subtitle. Highcharter default:
  `"Kilde: Navn av kilder"`.

- caption:

  Character or `NULL`. Caption text (highcharter only).

- xlab:

  Character or NULL. X-axis label.

  `" "` (default)

  :   Use the `x` column name from
      [`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md).

  `NULL`

  :   Hide the x-axis label completely.

  any string

  :   Use that string as the label.

- ylab:

  Character or NULL. Y-axis label. Same rules as `xlab`.

- ylim:

  Numeric vector of length 2 or `NULL`. Fixed y-axis limits, e.g.
  `c(0, 100)`.

- yint:

  Positive numeric. Y-axis tick interval. Default `10`.

- flip:

  Logical. Invert axes (horizontal bars). Default `FALSE`.

- colors:

  Character vector, palette name string, or `NULL`. Per-figure colour
  override; takes precedence over
  [`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md).

- hc_theme:

  Character or `NULL`. Per-figure highcharter theme name; takes
  precedence over
  [`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md).

## Value

An S3 object of class `"hd_opts"`.

## Details

Because opts are separate from
[`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md),
the same data mapping can be rendered with multiple styles without
repetition:

    spec    <- hd_spec(df, "age", "pct", group = "sex")
    opts_en <- hd_opts(title = "Health survey",    subtitle = "All ages")
    opts_no <- fig_opts(title = "Helseundersøkelse", subtitle = "Alle aldre")

    hd_make(spec, "column", opts_en)
    hd_make(spec, "column", opts_no)

## See also

[`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md),
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md),
[`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md)

## Examples

``` r
opts <- hd_opts(
  title    = "Health survey results",
  subtitle = "Source: FHI 2024",
  caption  = "Tall om helse",
  ylim     = c(0, 100),
  yint     = 20,
  colors   = c("#025169", "#7C145C")
)
opts
#> <hd_opts>
#>   title    : Health survey results 
#>   subtitle : Source: FHI 2024 
#>   caption  : Tall om helse 
#>   xlab     :   
#>   ylab     :   
#>   ylim     : 0 100 
#>   yint     : 20 
#>   flip     : FALSE 
#>   colors   : #025169, #7C145C 
```
