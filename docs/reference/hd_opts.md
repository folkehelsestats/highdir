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
  description = NULL,
  xlab = " ",
  ylab = " ",
  ylim = NULL,
  yint = 10,
  ysuffix = NULL,
  xtick_labels = NULL,
  decimals = NULL,
  flip = FALSE,
  colors = NULL,
  hc_theme = NULL,
  gg_theme = NULL
)
```

## Arguments

- title:

  Character or `NULL`. Chart title.

- subtitle:

  Character or `NULL`. Subtitle. Highcharter default:
  `"Kilde: Navn av kilder"`.

- caption:

  Character or `NULL`. Caption text displayed below the figure
  (highcharter only). This is a **visible** footnote, distinct from
  `description` which is read only by assistive technology.

- description:

  Character or `NULL`. Invisible accessibility description of the figure
  intended for screen readers and other assistive technology.

  highcharter

  :   Passed to `hc_accessibility(description = ...)`. Requires the
      accessibility module, which highdir loads automatically. Screen
      readers announce this text when the user focuses the chart.

  ggplot2

  :   Set as the `alt` label via `labs(alt = ...)`, available since
      ggplot2 3.3.0. Rendered as an HTML `alt` attribute when the plot
      is saved to SVG or included in an R Markdown / Quarto document
      with `fig.alt` support.

  Write a concise one- or two-sentence summary of what the figure shows,
  including the key trend or comparison, so the information is equally
  accessible to users who cannot see the chart. Example:
  `"Bar chart showing alcohol use by age group. Use is highest in the 45-54 age group at 65% and lowest in 18-24 at 42%."`

- xlab:

  Character or `NULL`. X-axis label.

  `" "` (default)

  :   Use the `x` column name from
      [`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md).

  `NULL`

  :   Hide the x-axis label completely.

  any string

  :   Use that string as the label.

- ylab:

  Character or `NULL`. Y-axis label. Same rules as `xlab`.

- ylim:

  Numeric vector of length 2 or `NULL`. Fixed y-axis limits, e.g.
  `c(0, 100)`.

- yint:

  Positive numeric. Y-axis tick interval. Default `10`.

- ysuffix:

  Character or `NULL`. String appended to every y-axis tick label, e.g.
  `"%"` or `" km"`. `NULL` shows no suffix.

- xtick_labels:

  Character or `NULL`. Column name supplying custom x-axis tick labels
  when the plotted x-values are numeric but the displayed labels should
  come from another column. Highcharter only. Note: Highcharts indexes
  categories from 0, not 1.

- decimals:

  Integer or `NULL`. Number of decimal places to round the y-values to
  before rendering. Applied to the data via `check_decimals()` in
  [`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md).
  `NULL` leaves values unchanged.

- flip:

  Logical. Invert axes (horizontal bars / inverted chart). Default
  `FALSE`.

- colors:

  Character vector, palette name string, or `NULL`. Per-figure colour
  override; takes precedence over
  [`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md).

- hc_theme:

  Character or `NULL`. Per-figure highcharter theme name; takes
  precedence over
  [`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md).
  See
  [`hd_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_theme.md)
  for valid names.

- gg_theme:

  Character name string, ggplot2 theme object, or `NULL`. Per-figure
  ggplot2 theme; takes precedence over
  [`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md).
  Name strings: `"classic"` (default), `"minimal"`, `"bw"`, `"light"`,
  `"dark"`, `"void"`, `"grey"`. Or pass a `ggplot2::theme_*()` object
  directly, e.g. `ggplot2::theme_bw(base_size = 14)`.

## Value

An S3 object of class `"hd_opts"`.

## Details

Because opts are separate from
[`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md),
the same data mapping can be rendered with multiple styles without
repetition:

    spec    <- hd_spec(df, "age", "pct", group = "sex")
    opts_en <- hd_opts(title = "Health survey",    subtitle = "All ages")
    opts_no <- hd_opts(title = "Helseundersøkelse", subtitle = "Alle aldre")

    hd_make(spec, "column", opts_en)
    hd_make(spec, "column", opts_no)

## See also

[`hd_spec()`](https://github.com/folkehelsestats/highdir/reference/hd_spec.md),
[`hd_make()`](https://github.com/folkehelsestats/highdir/reference/hd_make.md),
[`hd_set_theme()`](https://github.com/folkehelsestats/highdir/reference/hd_set_theme.md)

## Examples

``` r
opts <- hd_opts(
  title       = "Health survey results",
  subtitle    = "Source: FHI 2024",
  caption     = "Tall om helse",
  description = paste(
    "Grouped bar chart showing alcohol use by age group and sex.",
    "Use is highest in the 45-54 age group at 65% for women."
  ),
  ylim        = c(0, 100),
  yint        = 20,
  colors      = c("#025169", "#7C145C")
)
opts
#> <hd_opts>
#>   title        : Health survey results 
#>   subtitle     : Source: FHI 2024 
#>   caption      : Tall om helse 
#>   description  : Grouped bar chart showing alcohol use by age group and sex. Use is highest in... 
#>   xlab         :   
#>   ylab         :   
#>   ylim         : 0 100 
#>   yint         : 20 
#>   flip         : FALSE 
#>   colors       : #025169, #7C145C 
```
