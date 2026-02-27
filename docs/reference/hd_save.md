# Save a Figure to Disk

Exports a figure produced by
[`make_fig()`](https://github.com/folkehelsestats/highdir/reference/make_fig.md)
(or any `ggplot` / `highchart` object) to a file. The output format is
inferred from the file extension unless `type` is specified explicitly.

## Usage

``` r
hd_save(
  fig,
  file,
  type = "auto",
  width = 8,
  height = 5,
  dpi = 300,
  selfcontained = TRUE,
  delay = 0.8,
  ...
)
```

## Arguments

- fig:

  A `highchart` or `ggplot` object.

- file:

  Character. Output file path including extension, e.g.
  `"output/chart.html"` or `"output/chart.png"`.

- type:

  Character. Explicit format override. One of `"auto"` (infer from
  extension), `"html"`, `"json"`, `"png"`, `"svg"`, `"pdf"`, `"jpeg"`,
  `"tiff"`. Default: `"auto"`.

- width:

  Numeric. Output width. Inches for ggplot2; pixels for highcharter PNG.
  Default: `8`.

- height:

  Numeric. Output height. Inches for ggplot2; pixels for highcharter
  PNG. Default: `5`.

- dpi:

  Numeric. Resolution for raster ggplot2 exports. Default: `300`.

- selfcontained:

  Logical. For HTML export, embed all JS/CSS so the file is
  self-contained and portable. Default: `TRUE`.

- delay:

  Numeric. Seconds to wait for JavaScript to finish rendering before
  taking a PNG screenshot of a highcharter widget. Default: `0.8`.

- ...:

  Additional arguments forwarded to
  [`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)
  (ggplot2 figures only).

## Value

`file`, invisibly. Called primarily for its side-effect.

## Details

|             |                                     |
|-------------|-------------------------------------|
| Backend     | Supported formats                   |
| highcharter | `html`, `json`, `png`\*             |
| ggplot2     | `png`, `svg`, `pdf`, `jpeg`, `tiff` |

\*PNG for highcharter requires the **webshot2** package and a Chromium
browser. Install with `install.packages("webshot2")`.

## Examples

``` r
if (FALSE) { # \dontrun{
spec <- fig_spec(mtcars, "wt", "mpg", title = "Weight vs MPG")

# Highcharter
hc_fig <- make_fig(spec, "scatter", backend = "highcharter")
hd_save(hc_fig, "chart.html")
hd_save(hc_fig, "chart.json")
hd_save(hc_fig, "chart.png")   # requires webshot2

# ggplot2
gg_fig <- make_fig(spec, "scatter", backend = "ggplot2")
hd_save(gg_fig, "chart.png")
hd_save(gg_fig, "chart.svg")
hd_save(gg_fig, "chart.pdf")
} # }
```
